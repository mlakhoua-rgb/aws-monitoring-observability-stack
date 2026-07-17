# GitHub Services Monitoring - Real-World Use Case

**Author:** Mohamed Ben Lakhoua (AI-Augmented with Claude Code)
**License:** MIT
**Last Updated:** January 2026

## 📋 Overview

This guide demonstrates a real-world monitoring implementation for GitHub services, one of the world's most popular developer platforms. The monitoring stack tracks availability, performance, SSL certificate health, and provides comprehensive alerting.

## 🎯 What This Monitors

### Endpoints Monitored
1. **GitHub Website** - `https://github.com`
2. **GitHub API** - `https://api.github.com`
3. **GitHub Status API** - `https://www.githubstatus.com/api/v2/status.json`

The probe interval is deliberately 2 minutes: unauthenticated requests to
`api.github.com` are rate-limited to 60/hour/IP, and a monitoring tool that
gets itself rate-limited produces false DOWN alerts. Add more API endpoints
only if you also raise the interval or authenticate the probes.

### Metrics Collected
- **Availability**: Uptime percentage, probe success/failure
- **Response Times**: Total duration, DNS lookup, SSL handshake
- **HTTP Status Codes**: 200, 301, 404, 500, etc.
- **SSL Certificates**: Expiry dates, validity
- **SLA Compliance**: 99% availability threshold tracking

## 🚀 Quick Start - Local Testing

### Prerequisites
- Docker and Docker Compose installed
- At least 2GB RAM available
- Ports 3000, 9090, 9093, 9115 available

### Start the Stack

```bash
# Clone the repository (if not already done)
cd aws-monitoring-observability-stack

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

### Access the Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **Prometheus** | http://localhost:9090 | None |
| **AlertManager** | http://localhost:9093 | None |
| **Blackbox Exporter** | http://localhost:9115 | None |

### View the Dashboard

1. Open Grafana: http://localhost:3000
2. Login with `admin` / `admin` (change password when prompted)
3. Navigate to **Dashboards** → **GitHub Services Monitoring**
4. The dashboard will auto-refresh every 30 seconds

## 📊 Dashboard Panels Explained

### 1. Status Indicators (Top Row)
- **GitHub.com Status**: Real-time UP/DOWN status with color coding
- **GitHub API Status**: API endpoint availability
- **Overall Uptime (1h)**: Rolling 1-hour availability percentage
- **SSL Certificate Expiry**: Days remaining until certificate expiration

### 2. Response Time Graphs
- **Response Time - All Endpoints**: Shows HTTP request duration for all monitored URLs
- **DNS Resolution Time**: DNS lookup latency per endpoint
- **SSL/TLS Handshake Time**: Time taken for SSL negotiation

### 3. HTTP Monitoring
- **HTTP Status Codes**: Tracks status codes returned (200, 301, 404, 500)
- **Endpoint Summary Table**: Comprehensive table showing:
  - Current status (UP/DOWN)
  - Uptime percentage
  - Average response time
  - Last HTTP status code

### 4. Availability Trends
- **Availability Over Time**: 5-minute rolling average availability chart
  - Green zone (>99%): Healthy
  - Yellow zone (95-99%): Warning
  - Red zone (<95%): Critical

## 🔔 Alert Rules

### Critical Alerts (Immediate Action Required)

| Alert Name | Condition | Duration | Description |
|------------|-----------|----------|-------------|
| **GitHubDown** | `probe_success == 0` | 2 minutes | Endpoint is completely unreachable |
| **GitHubVerySlow** | Response time > 5s | 2 minutes | Critically slow response times |
| **GitHubHTTP5xx** | HTTP status ≥ 500 | 2 minutes | Server errors detected |
| **GitHubSLABreach** | Availability < 99% | 10 minutes | SLA threshold breached |
| **GitHubSSLCertExpiryCritical** | Certificate expires in < 7 days | 1 hour | SSL certificate about to expire |
| **GitHubMultipleEndpointsDown** | ≥2 endpoints down | 1 minute | Possible widespread outage |

### Warning Alerts (Investigation Needed)

| Alert Name | Condition | Duration | Description |
|------------|-----------|----------|-------------|
| **GitHubDegraded** | Availability < 95% | 5 minutes | Service degradation detected |
| **GitHubSlowResponse** | Response time > 2s | 5 minutes | Elevated latency |
| **GitHubHighDNSLatency** | DNS lookup > 1s | 5 minutes | DNS resolution issues |
| **GitHubSSLHandshakeSlow** | SSL handshake > 1s | 5 minutes | SSL negotiation delays |
| **GitHubHTTPError** | HTTP status 4xx | 3 minutes | Client errors detected |
| **GitHubSSLCertExpiringSoon** | Certificate expires in < 30 days | 1 hour | Plan SSL renewal |

## 🔧 Configuration Files

### Core Configuration Files

```
aws-monitoring-observability-stack/
├── prometheus/
│   ├── prometheus.yml          # Main Prometheus configuration
│   ├── blackbox.yml            # Blackbox exporter modules
│   └── alerts/
│       └── github_alerts.yml   # Alert rules
├── grafana/
│   ├── dashboards/
│   │   └── github_monitoring.json  # Dashboard definition
│   └── provisioning/
│       ├── datasources/
│       │   └── prometheus.yml      # Prometheus datasource
│       └── dashboards/
│           └── dashboards.yml      # Dashboard provider
├── alertmanager/
│   └── alertmanager.yml        # Alert routing and receivers
└── docker-compose.yml          # Local deployment orchestration
```

## 📈 Customizing the Monitoring

### Add More Endpoints

Edit `prometheus/prometheus.yml`:

```yaml
- job_name: 'github-http'
  metrics_path: /probe
  scrape_interval: 2m
  params:
    module: [http_2xx]
  static_configs:
    - targets:
        - https://github.com
        - https://api.github.com
        - https://www.githubstatus.com/api/v2/status.json
        - https://your-custom-endpoint.com  # Add here
```

### Adjust Scrape Intervals

```yaml
scrape_configs:
  - job_name: 'github-http'
    scrape_interval: 1m  # fine for your own endpoints; mind rate limits on shared APIs
```

### Modify Alert Thresholds

Edit `prometheus/alerts/github_alerts.yml`:

```yaml
- alert: GitHubSlowResponse
  expr: probe_duration_seconds{job="github-http"} > 1  # Change from 2s to 1s
  for: 3m  # Change from 5m to 3m
```

## 🔐 Production Deployment on AWS

### Prerequisites
- AWS account with appropriate permissions
- Terraform 1.6+ installed
- Existing VPC with public and private subnets

### Deploy Infrastructure

```bash
cd terraform

# Initialize Terraform
terraform init

# Create terraform.tfvars from the example
cp terraform.tfvars.example terraform.tfvars
# then edit vpc_id, subnet IDs, and grafana_admin_password

# Review plan
terraform plan

# Deploy
terraform apply
```

### Access Production Dashboard

After deployment:

1. Get the Grafana ALB URL from Terraform outputs:
   ```bash
   terraform output grafana_url
   ```

2. Access Grafana at the ALB URL
3. Login with credentials from terraform.tfvars
4. The GitHub monitoring dashboard will be available

## 📊 Understanding the Metrics

### Key Prometheus Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `probe_success` | 1 if probe succeeded, 0 if failed | Gauge |
| `probe_duration_seconds` | Total probe duration | Gauge |
| `probe_http_duration_seconds` | HTTP request duration | Gauge |
| `probe_dns_lookup_time_seconds` | DNS resolution time | Gauge |
| `probe_http_duration_seconds{phase="tls"}` | SSL/TLS handshake duration (per-phase breakdown) | Gauge |
| `probe_http_status_code` | HTTP status code returned | Gauge |
| `probe_ssl_earliest_cert_expiry` | SSL certificate expiry timestamp | Gauge |

### Example PromQL Queries

**Calculate uptime percentage over 24 hours:**
```promql
avg_over_time(probe_success{job="github-http"}[24h]) * 100
```

**Get 95th percentile response time:**
```promql
# probe_duration_seconds is a gauge (no histogram buckets) —
# use quantile_over_time, not histogram_quantile
quantile_over_time(0.95, probe_duration_seconds{job="github-http"}[1h])
```

**Count failed probes in last hour:**
```promql
count_over_time((probe_success{job="github-http"} == 0)[1h:])
```

**SSL certificate days remaining:**
```promql
(probe_ssl_earliest_cert_expiry{job="github-ssl"} - time()) / 86400
```

## 🧪 Testing Alerts

### Simulate Downtime

Test alert firing by temporarily blocking an endpoint:

```bash
# Block github.com resolution on the host (sudo must own the redirection,
# hence tee — `sudo echo >> file` would fail on a root-owned file):
echo "127.0.0.1 github.com" | sudo tee -a /etc/hosts

# Wait for the next probe cycle (2m interval) plus the alert's 2m `for`
# duration, then check AlertManager: http://localhost:9093

# Remove the entry to restore
sudo sed -i '/127.0.0.1 github.com/d' /etc/hosts
```

### View Active Alerts

1. **In Prometheus UI**: http://localhost:9090/alerts
2. **In AlertManager UI**: http://localhost:9093
3. **In Grafana**: Dashboard will show red status indicators

## 🎓 Learning Outcomes

This real-world example demonstrates:

1. **Blackbox Monitoring**: External monitoring without instrumenting the application
2. **Multi-endpoint Tracking**: Monitoring multiple related services simultaneously
3. **SLA Monitoring**: Tracking and alerting on uptime SLAs
4. **Performance Metrics**: Beyond availability - latency, DNS, SSL metrics
5. **Alert Hierarchy**: Critical vs warning alerts with proper thresholds
6. **Dashboard Design**: Information hierarchy and visual clarity
7. **Production Patterns**: High availability Grafana with ALB and Auto Scaling

## 🔍 Troubleshooting

### Prometheus Not Scraping
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq

# Check Blackbox Exporter logs
docker-compose logs blackbox-exporter
```

### Dashboard Shows No Data
1. Verify Prometheus is scraping: http://localhost:9090/targets
2. Check if data exists: http://localhost:9090/graph
   - Query: `probe_success{job="github-http"}`
3. Verify Grafana datasource: Configuration → Data Sources → Prometheus

### Alerts Not Firing
```bash
# Check alert rules are loaded in Prometheus
curl http://localhost:9090/api/v1/rules | jq

# Check AlertManager configuration
curl http://localhost:9093/api/v2/status | jq
```

## 🚀 Next Steps

### Extend This Monitoring

1. **Add More Services**: Apply the same pattern to monitor:
   - Your own APIs and websites
   - Cloud provider status pages (AWS, GCP, Azure)
   - CDN endpoints (Cloudflare, Fastly)
   - Third-party services your app depends on

2. **Implement Synthetic Transactions**:
   - Multi-step user flows
   - API authentication and data validation
   - Geographic monitoring from multiple regions

3. **Add Custom Exporters**:
   - Application-specific metrics
   - Business KPIs
   - Custom health checks

4. **Enhance Alerting**:
   - Integrate with PagerDuty, OpsGenie
   - Set up Slack/Teams notifications
   - Create runbooks for each alert

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/best-practices/)
- [Blackbox Exporter Guide](https://github.com/prometheus/blackbox_exporter)
- [AlertManager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)

## 🤝 Contributing

This project is AI-augmented and open for contributions:
- Report issues or bugs
- Suggest improvements
- Add new dashboards or alerts
- Share your monitoring patterns

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

---

**Built with ❤️ using AI-Augmented Development**

*This monitoring stack demonstrates production-ready observability patterns using modern tools and best practices.*
