# AWS Monitoring & Observability Stack — Troubleshooting

Common issues, their causes, and fixes.

## Local lab (Docker Compose)

### `docker compose up` fails or a container restarts in a loop

Check which one and read its logs first:

```bash
docker compose ps
docker compose logs <service> --tail 50
```

- **prometheus** restarting: almost always a config error — validate with
  `docker run --rm -v $(pwd)/prometheus:/cfg --entrypoint promtool prom/prometheus:v2.45.0 check config /cfg/prometheus.yml`
- **grafana** restarting: usually a bad provisioning file under `grafana/provisioning/`.
- **cloudwatch-exporter** exits immediately: it only runs under the `aws` profile and needs `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` in the environment. With SSO or otherwise federated credentials, `AWS_SESSION_TOKEN` is required as well — without it the scrape fails with 403 "The security token included in the request is invalid". Export all three, e.g. `eval "$(aws configure export-credentials --profile YOUR_PROFILE --format env)"`.

### CloudWatch metrics don't appear with `--profile aws`

Three separate switches must all be on:

1. **The scrape target:** copy `prometheus/targets/cloudwatch.yml.example` to `prometheus/targets/cloudwatch.yml` — the `cloudwatch` job is file_sd-based and empty by default (so the plain lab shows no dead target). Prometheus picks the file up without a restart.
2. **The region:** the exporter queries the `region` set in `cloudwatch-exporter/config.yml`; an `AWS_REGION` environment variable does **not** override it. Edit the file for any region other than us-east-1.
3. **Credentials:** `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` must be in the compose environment, plus `AWS_SESSION_TOKEN` for SSO/federated credentials; check `docker compose logs cloudwatch-exporter` for auth errors.

Also remember CloudWatch metrics lag by several minutes and the scrape interval is 5m — first datapoints take a while.

### GitHub dashboard shows "No data"

Work down the pipeline:

1. **Probe layer:** `curl 'http://localhost:9115/probe?module=http_2xx&target=https://github.com'` — should print `probe_success 1`.
2. **Scrape layer:** http://localhost:9090/targets — the `github-http` job must be UP. First data can take one probe cycle (2 minutes).
3. **Query layer:** in http://localhost:9090/graph run `probe_success{job="github-http"}`.
4. **Dashboard layer:** if Prometheus has the data but panels are empty, the datasource uid doesn't match — the provisioned datasource must have `uid: prometheus` (it does in this repo; check if you edited it).

### Alerts never fire

- Rules loaded? http://localhost:9090/rules must list both `alert_rules/` and `alerts/` groups — both directories are mounted in docker-compose and referenced in `prometheus.yml`.
- Remember each alert's `for:` duration on top of the 2-minute probe interval: `GitHubDown` needs ~4 minutes of real downtime to page.

### Grafana login rejected

Default is `admin` / `admin` unless you set `GRAFANA_ADMIN_PASSWORD`. The password env var only applies on the *first* start of a fresh volume — after that Grafana stores it in its database: `docker compose down -v` resets everything (destroys dashboards you saved manually too).

### Ports already in use

The lab claims 3000, 9090, 9093, 9100, 9115 (plus 9106/3100 with profiles). Stop the conflicting service or remap in a compose override file.

## AWS deployment (Terraform)

### ALB shows targets unhealthy / Grafana URL 502s

- Health check is `/api/health` on :3000. `502/unhealthy` right after apply usually just means user_data is still installing Docker — grace period is 300s.
- If it persists: SSM into the instance (`aws ssm start-session --target <id>`) and check `docker logs grafana`.
- Verify the Grafana SG allows :3000 **from the ALB SG** (it does in this repo's config; check if you replaced the SGs).

### Prometheus has no node-exporter targets

- The scraped instances need the tag `Monitoring=enabled`, state running, and node-exporter listening on :9100.
- **Their** security groups must allow the Prometheus SG on :9100 — this stack deliberately does not edit other resources' SGs.
- The Prometheus instance role needs `ec2:DescribeInstances` (included). If you swapped roles, service discovery fails with `AuthFailure` in `docker logs prometheus`.

### Grafana datasource missing after deploy

The datasource is provisioned by user_data at first boot. If the instance was replaced by the ASG before user_data finished, terminate it and let the ASG recreate it; check `/var/log/cloud-init-output.log` via SSM for script errors.

### `terraform apply` fails creating the ALB

- ALBs need at least two subnets in different AZs — `public_subnet_ids` must contain two.
- `aws_lb` names are limited to 32 characters — a long `project_name` overflows it.

## CI

### promtool job fails on a config that "works locally"

CI validates **both** configs (`prometheus.yml`, `prometheus-aws.yml`) and **all** rule files in both `alert_rules/` and `alerts/`. A rule file you added but never loaded locally still gets checked — which is the point.

### tfsec findings

The tfsec job is advisory (`soft_fail`) and will note, correctly, that the ALB is HTTP-only and SG egress is open. These are documented demo trade-offs — see the production hardening checklist in [DEPLOYMENT.md](DEPLOYMENT.md).
