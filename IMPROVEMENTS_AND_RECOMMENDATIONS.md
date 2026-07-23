# Roadmap & Future Improvements

**Author:** Mohamed Ben Lakhoua — developed with AI assistance (Claude Code) under human review
**Last Updated:** July 2026

Planned enhancements for the AWS Monitoring & Observability Stack, in priority order. Items that are already implemented (GitHub blackbox demo, CloudWatch exporter, Loki log aggregation, CI validation pipeline) are documented in the [README](README.md) and not repeated here.

---

## High priority

### 1. Additional dashboards

Three dashboards ship today (GitHub monitoring, EC2 instance monitoring, and a two-panel AWS infrastructure starter). Natural next additions:

| Dashboard | Purpose |
|---|---|
| System overview | Whole-stack health at a glance |
| RDS monitoring | Database observability |
| ALB monitoring | Load balancer latency, targets, error rates |
| Lambda monitoring | Serverless invocations, duration, errors |

### 2. Multi-environment support

The Terraform takes a single `environment` variable but has no per-environment configuration. Add environment-specific tfvars (or workspaces) so dev/staging can run smaller instances and looser alert thresholds than production:

```
terraform/environments/
├── dev.tfvars
├── staging.tfvars
└── production.tfvars
```

### 3. Remote state backend

A commented `backend "s3"` block already exists in `terraform/main.tf`. For anything beyond a personal sandbox, enable it with a versioned, encrypted S3 bucket and a DynamoDB lock table. This is a configuration step, not new code.

### 4. Optional networking module

The stack currently requires an existing VPC with public and private subnets. An optional `terraform/modules/vpc/` module (VPC, subnets, NAT gateway, VPC endpoints) would make the deployment self-contained for users without a network to deploy into.

---

## Medium priority

### 5. Automated infrastructure tests

CI validates configuration syntax but nothing exercises the Terraform modules themselves. Add Terratest (or `terraform test`) coverage for module outputs and security group rules.

### 6. Terraform plan/apply automation

The existing CI pipeline validates Terraform, Prometheus, Alertmanager, dashboards, and Compose files on every change. A next step is `terraform plan` output on pull requests (apply remains a deliberate manual step).

### 7. Monitoring-as-code for dashboards

Dashboards are hand-written JSON today. Generating them with Grafonnet or Jsonnet would give reusable components and make review diffs meaningful.

### 8. Cost optimization

The defaults (t3.medium Prometheus, t3.small Grafana) are conservative. Options worth evaluating per deployment: Graviton (t4g) instances, smaller dev sizes, and tiered retention (short local retention plus `remote_write` to long-term storage).

### 9. Security hardening

Already documented as deliberate demo limitations — the production path is: ACM certificate + HTTPS listener on the ALB, Grafana admin credentials from Secrets Manager (or SSO/OAuth), and restricted `alb_allowed_cidr_blocks`. See the hardening checklist in [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md#production-hardening-checklist).

### 10. Advanced alerting

- Anomaly-detection-style rules (e.g. value outside mean ± 2σ of a trailing window)
- Composite alerts across symptoms
- Routing by team ownership with escalation policies
- Runbook links in alert annotations (the demo alerts already have runbook entries in [docs/RUNBOOKS.md](docs/RUNBOOKS.md))

### 11. Distributed tracing

Metrics and logs are covered; traces are not. Integrate AWS X-Ray or a Grafana Tempo data source to complete the three-pillar picture.

---

## Lower priority

- **SLO/SLI tracking** — error budgets and SLO-based burn-rate alerting (the GitHub demo already tracks a 99% availability threshold as a starting point)
- **Multi-region monitoring** — cross-region scrape or federation with a global view
- **Backup & disaster recovery** — automated Prometheus TSDB snapshots to S3 and a restore runbook

---

## Contributing

Contributions in any of the areas above are welcome — open an issue first to align on the approach. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
