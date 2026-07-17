# AWS Monitoring & Observability Stack — Deployment Guide

Step-by-step instructions for deploying the stack to AWS with Terraform. For the local Docker Compose lab, see the [README quick start](../README.md#quick-start--working-demo-in-one-command).

## Prerequisites

- **AWS account** with permissions to create EC2, ALB, Auto Scaling, IAM, and security group resources.
- **AWS CLI** configured (`aws configure`).
- **Terraform** ≥ 1.6.0.
- **An existing VPC** with at least two private subnets (Grafana ASG + Prometheus) and two public subnets (ALB). The stack does not create the network.

## Step 1: Clone the repository

```bash
git clone https://github.com/mlakhoua-rgb/aws-monitoring-observability-stack.git
cd aws-monitoring-observability-stack/terraform
```

## Step 2 (recommended): Remote state backend

For anything beyond a personal sandbox, uncomment and configure the `backend "s3"` block in `main.tf`, using a versioned, encrypted S3 bucket.

## Step 3: Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

| Variable | Meaning |
|---|---|
| `vpc_id`, `private_subnet_ids`, `public_subnet_ids` | The network to deploy into (ALB uses the public subnets; instances the private ones) |
| `grafana_admin_password` | Grafana admin login. Note: delivered via user_data — see the security note below |
| `alb_allowed_cidr_blocks` | Who can reach the Grafana ALB on :80 (default: everyone; restrict to office/VPN ranges where possible) |
| `trusted_cidr_blocks` | Who may reach Prometheus :9090 directly (operators; Grafana's access is wired separately by security group) |
| `prometheus_instance_type` / `grafana_instance_type` | Sizing; defaults t3.medium / t3.small |

## Step 4: Deploy

```bash
terraform init
terraform plan    # review: 2 modules, security groups, IAM role
terraform apply
```

## Step 5: Verify

1. **Grafana:** `terraform output grafana_url` → open it, log in as `admin` with your configured password. The Prometheus datasource is already provisioned (written by user_data) — **Connections → Data sources → Prometheus → Test** should pass. Allow a few minutes after apply for user_data to finish on first boot.
2. **Prometheus targets:** from a host inside `trusted_cidr_blocks`: `curl http://<prometheus_private_ip>:9090/api/v1/targets`. Instances tagged `Monitoring=enabled` (running node-exporter on :9100) appear as targets automatically.
3. **ALB health:** the target group health check is `/api/health`; a `healthy` target means Grafana is actually serving, not just the instance running.

## Step 6: Point Prometheus at your workloads

Tag any EC2 instance you want scraped:

- `Monitoring=enabled` — node-exporter on :9100 (install it on the instance)
- `MetricsPort=8080` — custom application `/metrics` endpoint

Security groups on *those* instances must allow the Prometheus SG on the scrape port — the stack cannot open other teams' security groups for you, by design.

## Import the dashboards

The AWS deployment provisions the datasource but not the dashboard files. Import them via the Grafana UI (**Dashboards → New → Import**, upload from `grafana/dashboards/`) or the HTTP API:

```bash
for d in ../grafana/dashboards/*.json; do
  curl -s -X POST "http://<grafana-url>/api/dashboards/db" \
    -H "Content-Type: application/json" \
    -u "admin:<password>" \
    -d "{\"dashboard\": $(cat "$d"), \"overwrite\": true}"
done
```

## Production hardening checklist

Before treating this as more than a demo (also listed in [ARCHITECTURE.md](ARCHITECTURE.md) → Deliberate limitations):

- [ ] HTTPS listener with an ACM certificate on the ALB; redirect :80
- [ ] Grafana admin credentials from Secrets Manager, or SSO/OAuth
- [ ] `remote_write` to Amazon Managed Prometheus or Thanos for durable metrics
- [ ] Deploy/point to an Alertmanager and wire real receivers
- [ ] Restrict `alb_allowed_cidr_blocks` to known ranges

## Destroying the infrastructure

```bash
terraform destroy
```

This removes only the monitoring stack's own resources; Prometheus TSDB data on the instance is lost with it.
