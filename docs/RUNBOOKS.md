# Runbooks

What to do when each alert fires. Format per alert: *meaning → first checks → actions → escalation*. These are written for the demo stack; adapt owners and escalation paths to your team.

General rule: **check for an active provider incident before debugging your own stack** — for the GitHub demo alerts, that's https://www.githubstatus.com.

---

## GitHub demo alerts (`prometheus/alerts/github_alerts.yml`)

### GitHubDown (critical)

**Meaning:** an endpoint failed every probe for 2+ minutes (with the 2m probe interval: ~4 minutes real time).

1. Check https://www.githubstatus.com — if GitHub reports an incident, this alert is working as intended; nothing to fix locally.
2. Verify it's not the monitor: `curl -I https://github.com` from the host running the stack; then `curl 'http://localhost:9115/probe?module=http_2xx&target=https://github.com'`.
3. If the probe fails but the direct curl succeeds: blackbox-exporter problem (DNS inside the container, egress firewall, rate limiting). Check `docker compose logs blackbox-exporter`.
4. **Inhibition note:** related latency/DNS/TLS warnings for the same endpoint are suppressed automatically while this fires.

### GitHubDegraded (warning)

**Meaning:** availability under 95% over 5 minutes — flapping, not hard-down.

1. Look at the availability panel: regular dips suggest rate limiting (probes too frequent?) or network instability on the monitoring host.
2. Check probe duration trends — timeouts count as failures; a `timeout: 10s` probe against a slow endpoint flaps.

### GitHubSlowResponse / GitHubVerySlow (warning / critical)

**Meaning:** total probe duration above 2s / 5s.

1. Identify the slow phase in the response-time panel (DNS, TCP, TLS, transfer breakdown via `probe_http_duration_seconds`).
2. Slow from your monitor but fine from elsewhere (test with an online checker) → local network path, not the target.
3. For critical: treat as user-facing; if your product depends on the endpoint, activate your dependency-degradation plan (caching, circuit breaker, status banner).

### GitHubHighDNSLatency (warning)

**Meaning:** DNS resolution above 1s.

1. Check the resolver the container uses (`docker exec blackbox-exporter cat /etc/resolv.conf`).
2. Test an alternative resolver from the host (`dig @1.1.1.1 github.com` vs default).
3. Persistent across resolvers → upstream DNS issue; transient → note and monitor.

### GitHubSSLHandshakeSlow (warning)

**Meaning:** TLS phase of the probe above 1s. Usually a symptom of general latency — check `GitHubSlowResponse` first; isolated TLS slowness across endpoints points at the monitoring host's CPU or MTU issues.

### GitHubSSLCertExpiringSoon / GitHubSSLCertExpiryCritical (warning / critical)

**Meaning:** certificate expires within 30 / 7 days. For third-party endpoints (as in the demo) this is informational — the provider rotates certificates. **For your own endpoints, this is the alert that prevents an outage:** confirm auto-renewal (ACM, certbot) actually ran, and renew manually if not.

### GitHubHTTPError / GitHubHTTP5xx (warning / critical)

**Meaning:** endpoint answering with 4xx / 5xx.

1. 4xx on an API endpoint: check for `403` rate limiting first (`curl -sI https://api.github.com | grep -i ratelimit`) — self-inflicted rate limiting is the most common cause in this demo.
2. 5xx: provider-side; confirm on the status page, correlate with `GitHubDown`.

### GitHubSLABreach (critical)

**Meaning:** fleet-wide availability below 99% over the last hour. This is the report-facing alert: record the window, affected endpoints, and root cause; if you owe SLA credits or reports downstream, this is the evidence trail.

### GitHubMultipleEndpointsDown (critical)

**Meaning:** 2+ endpoints down simultaneously — widespread outage (theirs) or broken egress (yours).

1. If *everything* is down including unrelated endpoints, suspect your own network/DNS first.
2. Confirm on the provider status page; open your incident channel either way.

---

## Infrastructure alerts (`prometheus/alert_rules/infrastructure.yml`)

### InstanceDown (critical)

**Meaning:** a scrape target stopped answering.

1. Distinguish "instance gone" from "exporter gone": can you SSM into it? Is it terminated in the EC2 console, or did node-exporter crash (`systemctl status node_exporter`)?
2. Autoscaling churn produces expected InstanceDown flaps — if that's noisy, filter targets to long-lived instances or drop terminated instances faster via SD refresh.

### HighCPUUsage / HighMemoryUsage (warning)

1. `top`/`htop` via SSM: one process or systemic load?
2. Sustained high CPU with a healthy app → undersized instance: resize or scale out.
3. Memory growth without bound → suspect a leak; capture evidence (process, growth rate) before restarting.

### DiskSpaceLow (critical, <15% free)

1. Find the consumer: `du -xh --max-depth=2 / | sort -rh | head -20`.
2. Usual suspects: logs without rotation, Docker images/volumes (`docker system df`), TSDB growth on the Prometheus host itself.
3. Free space (rotate/prune), then fix the source; expand the volume only when legitimate growth demands it.

### HighNetworkErrors (warning)

1. `ip -s link` on the instance — errors vs drops.
2. Correlate with instance type network limits (t3 burst credits); persistent errors on multiple instances in one subnet → escalate to network/AWS support.

### ALBHighResponseTime (warning)

1. Check target health first — a dying target skews the average.
2. Correlate with backend CPU/memory alerts above; ALB latency is almost always backend latency.

### RDSHighCPU (warning)

1. Check active queries (`pg_stat_activity` / Performance Insights).
2. New deploy correlated? A missing index or N+1 pattern is likelier than "database too small."
3. Scale instance class only after query analysis.

### S3HighErrorRate (warning)

**Meaning:** elevated 4xx on a bucket with request metrics enabled. Mostly permission drift (403) or clients requesting deleted keys (404) — check CloudTrail for the calling principal.

---

## After any incident

- Note timeline, cause, and fix — even two sentences beats nothing.
- If the alert was noise: tune the threshold or add an inhibition rule instead of ignoring it. An alert nobody acts on trains people to ignore the pager.
