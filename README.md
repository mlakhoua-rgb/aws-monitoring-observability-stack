# AWS Monitoring & Observability Stack

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)](https://www.terraform.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-2.45+-E6522C?logo=prometheus)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-10.0+-F46800?logo=grafana)](https://grafana.com/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![AI-Augmented](https://img.shields.io/badge/AI--Augmented-Manus%20AI-blueviolet)](https://www.manus.im/)

**AI-Augmented Observability: Demonstrating SRE Best Practices for AWS Infrastructure Monitoring**

This repository showcases a production-ready, generic AWS monitoring and observability stack using Prometheus, Grafana, and CloudWatch. The project was developed with AI assistance to demonstrate how platform engineering leaders can implement comprehensive monitoring solutions while maintaining human oversight of reliability engineering and incident response.

**Purpose:** Educational example demonstrating SRE best practices, infrastructure observability, and proactive monitoring for AWS environments. All configurations are generic, reusable, and safe for public sharing.

**Repository:** [https://github.com/mlakhoua-rgb/aws-monitoring-observability-stack](https://github.com/mlakhoua-rgb/aws-monitoring-observability-stack)

---

## 🤖 AI-Augmented Development Approach

### Human-AI Collaboration Model

This observability stack was developed using an orchestrated AI collaboration model where experienced SRE and platform engineering leaders leverage AI agents for specific development tasks while maintaining strategic oversight of reliability engineering and incident management.

**AI Agents Used:**
- **Manus AI**: Primary agent for Terraform module development, Prometheus configuration, and Grafana dashboard creation
- **Claude**: Code review, architecture validation, SRE best practices, and security analysis
- **Gemini**: Data analysis, metric selection, and dashboard optimization
- **Perplexity**: Research on Prometheus exporters, Grafana plugins, and CloudWatch integration patterns
- **ChatGPT**: Rapid prototyping, AlertManager configuration, and troubleshooting

**Human Oversight:**
- Strategic monitoring strategy and SLO/SLI definition
- Incident response procedures and escalation policies
- Alert threshold tuning and false positive reduction
- Production deployment approval and change management
- On-call rotation and team coordination

### SRE Best Practices with AI Integration

This repository demonstrates how AI agents can be integrated into SRE workflows for:

- **Automated Dashboard Creation**: AI-assisted generation of Grafana dashboards with human validation of metrics
- **Alert Rule Development**: AI-powered alert rule suggestions with human tuning of thresholds
- **Documentation Generation**: AI-augmented creation of runbooks and troubleshooting guides
- **Metric Selection**: AI-assisted identification of key performance indicators with human prioritization
- **Capacity Planning**: AI-powered analysis of resource utilization trends with human decision-making

**Key Principle**: Experienced SRE leaders orchestrate AI agents to accelerate observability implementation while maintaining accountability for reliability, incident response, and production stability that should never be fully automated without human oversight.

---

## 🎯 Project Overview

This monitoring stack provides comprehensive observability for AWS infrastructure, enabling teams to detect issues proactively, troubleshoot efficiently, and maintain high availability. It combines the power of Prometheus for metrics collection, Grafana for visualization, and CloudWatch for native AWS service monitoring.

**Key Features:**
- **Prometheus Deployment**: Complete Terraform deployment of Prometheus on AWS EC2 with persistent storage
- **Grafana Dashboards**: Pre-built dashboards for EC2, RDS, ALB, Lambda, and cost monitoring
- **CloudWatch Integration**: Unified monitoring across Prometheus and CloudWatch metrics
- **AlertManager**: Comprehensive alerting with SNS, Slack, and email notifications
- **High Availability**: Auto-scaling and multi-AZ deployment for production reliability
- **Security Hardening**: SSL/TLS encryption, IAM roles, and security group controls
- **Cost Optimization**: Right-sized instances and efficient metric retention policies

---

## 🏗️ Architecture Overview

The monitoring stack consists of several integrated components deployed across AWS services.

### Component Architecture

The system is organized into four main layers that provide end-to-end observability. The **Data Collection Layer** uses Prometheus to scrape metrics from AWS services, custom applications, and infrastructure components through various exporters (Node Exporter, CloudWatch Exporter, Blackbox Exporter). The **Storage Layer** persists metrics in Prometheus TSDB with configurable retention periods and uses EBS volumes for durability. The **Visualization Layer** provides Grafana dashboards for real-time monitoring, historical analysis, and custom queries, with pre-built dashboards for common AWS services. The **Alerting Layer** uses AlertManager to process alert rules, deduplicate notifications, and route alerts to appropriate channels (SNS, Slack, email) based on severity and team ownership.

### Data Flow

Metrics flow from AWS services and applications to Prometheus through service discovery and scraping. Prometheus evaluates alert rules continuously and forwards firing alerts to AlertManager. Grafana queries Prometheus for dashboard visualization and CloudWatch for native AWS metrics. AlertManager processes alerts, applies silencing and inhibition rules, and sends notifications to configured receivers. All components log to CloudWatch Logs for centralized troubleshooting and audit trails.

### High Availability Design

The stack is deployed across multiple availability zones for resilience. Prometheus uses persistent EBS volumes with automated snapshots for data durability. An Application Load Balancer distributes traffic to Grafana instances in an Auto Scaling Group. AlertManager runs in clustered mode for high availability and alert deduplication. CloudWatch provides backup monitoring and alerting in case of Prometheus failures.

---

## 📦 Technology Stack

### Core Monitoring Technologies
- **Prometheus 2.45+**: Time-series database and monitoring system
- **Grafana 10.0+**: Visualization and dashboarding platform
- **AlertManager 0.26+**: Alert routing and notification management
- **Node Exporter**: System-level metrics collection
- **CloudWatch Exporter**: AWS CloudWatch metrics integration

### AWS Services
- **EC2**: Compute instances for Prometheus and Grafana
- **EBS**: Persistent storage for metrics and dashboards
- **ALB**: Load balancing for Grafana high availability
- **Auto Scaling**: Dynamic scaling for Grafana instances
- **CloudWatch**: Native AWS metrics and logs
- **SNS**: Alert notification delivery
- **IAM**: Security and access control
- **VPC**: Network isolation and security groups

### Infrastructure as Code
- **Terraform 1.6+**: Complete infrastructure deployment
- **Docker**: Containerization for monitoring components
- **Docker Compose**: Local development and testing

### Supporting Tools
- **Nginx**: Reverse proxy and SSL termination
- **Let's Encrypt**: Free SSL/TLS certificates
- **Certbot**: Automated certificate management

---

## 🚀 Getting Started

### Prerequisites

**Required Tools:**
- Terraform 1.6 or higher
- AWS CLI 2.x
- Docker and Docker Compose (for local testing)
- Git for version control

**AWS Account Requirements:**
- AWS account with appropriate permissions
- IAM user with programmatic access
- Sufficient service quotas for EC2, ALB, and EBS
- VPC with public and private subnets

**Permissions Required:**
The IAM user needs permissions for:
- EC2 (instances, security groups, AMI, launch templates)
- VPC (VPC, subnets, route tables, internet gateways)
- ELB (application load balancers, target groups)
- EBS (volumes, snapshots)
- IAM (roles, policies, instance profiles)
- CloudWatch (metrics, logs, alarms)
- SNS (topics, subscriptions)
- Auto Scaling (groups, policies, launch configurations)

---

## 📊 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/mlakhoua-rgb/aws-monitoring-observability-stack.git
cd aws-monitoring-observability-stack
```

### 2. Configure AWS Credentials

```bash
# Option 1: Using AWS CLI
aws configure

# Option 2: Using environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 3. Prepare Terraform Configuration

```bash
cd terraform/environments/dev

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Example terraform.tfvars:**
```hcl
aws_region        = "us-east-1"
environment       = "dev"
vpc_id            = "vpc-xxxxx"
private_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
public_subnet_ids  = ["subnet-zzzzz", "subnet-aaaaa"]
alert_email       = "your-email@example.com"
grafana_admin_password = "change-me-securely"
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the monitoring stack
terraform apply
```

### 5. Access Grafana

After deployment completes, Terraform will output the Grafana URL:

```bash
# Get Grafana URL
terraform output grafana_url

# Default credentials
Username: admin
Password: (from terraform.tfvars)
```

### 6. Import Pre-built Dashboards

```bash
# Navigate to dashboards directory
cd ../../../grafana/dashboards

# Import dashboards via Grafana UI or API
for dashboard in *.json; do
  curl -X POST http://grafana-url/api/dashboards/db \
    -H "Content-Type: application/json" \
    -u admin:password \
    -d @$dashboard
done
```

---

## 🔧 Key Components

### Prometheus Configuration

**Location:** `prometheus/prometheus.yml`

Prometheus is configured to scrape metrics from multiple sources with service discovery for dynamic AWS environments.

**Key Features:**
- EC2 service discovery for automatic target detection
- CloudWatch Exporter for AWS native metrics
- Node Exporter for system-level metrics
- Blackbox Exporter for endpoint monitoring
- Custom application metrics via /metrics endpoints

**Scrape Intervals:**
- System metrics: 15 seconds
- Application metrics: 30 seconds
- CloudWatch metrics: 5 minutes (to respect API limits)

### Grafana Dashboards

**Location:** `grafana/dashboards/`

Pre-built dashboards provide immediate visibility into AWS infrastructure and application performance.

#### EC2 Monitoring Dashboard
- CPU, memory, disk, and network utilization
- Instance health and status
- Auto Scaling group metrics
- Cost per instance

#### RDS Monitoring Dashboard
- Database connections and queries
- Read/write IOPS and latency
- Storage utilization
- Replication lag (for Multi-AZ)

#### ALB Monitoring Dashboard
- Request count and error rates
- Target health status
- Response times (p50, p95, p99)
- Active connections

#### Lambda Monitoring Dashboard
- Invocation count and duration
- Error rate and throttles
- Concurrent executions
- Cold start frequency

#### Cost Monitoring Dashboard
- Daily AWS spending trends
- Cost by service
- Budget vs. actual
- Forecasted monthly cost

### AlertManager Configuration

**Location:** `alertmanager/alertmanager.yml`

AlertManager routes alerts to appropriate teams and channels based on severity and service ownership.

**Alert Routing:**
- **Critical**: SNS + Slack + Email (immediate notification)
- **Warning**: Slack + Email (15-minute grouping)
- **Info**: Email only (1-hour grouping)

**Notification Channels:**
- SNS topics for PagerDuty integration
- Slack webhooks for team channels
- Email for detailed alert context

---

## 📈 Pre-built Dashboards

### Dashboard Catalog

All dashboards are located in `grafana/dashboards/` and can be imported via the Grafana UI.

| Dashboard | File | Description |
|-----------|------|-------------|
| EC2 Overview | `ec2_monitoring.json` | Comprehensive EC2 instance monitoring |
| RDS Performance | `rds_monitoring.json` | Database performance and health |
| ALB Metrics | `alb_monitoring.json` | Load balancer traffic and latency |
| Lambda Functions | `lambda_monitoring.json` | Serverless function observability |
| Cost Analysis | `cost_monitoring.json` | AWS spending and budget tracking |
| System Overview | `system_overview.json` | High-level infrastructure health |

### Dashboard Screenshots

Each dashboard includes:
- Real-time metric visualization
- Historical trend analysis
- Alert status indicators
- Quick links to AWS Console
- Customizable time ranges
- Template variables for filtering

---

## 🚨 Alert Rules

**Location:** `prometheus/alerts/`

Alert rules are organized by service and severity level.

### Critical Alerts

**high_cpu_usage.yml**: CPU utilization > 90% for 5 minutes  
**high_memory_usage.yml**: Memory utilization > 90% for 5 minutes  
**disk_space_low.yml**: Disk usage > 85%  
**instance_down.yml**: EC2 instance unreachable  
**database_connections_high.yml**: RDS connections > 80% of max

### Warning Alerts

**elevated_cpu_usage.yml**: CPU utilization > 75% for 15 minutes  
**elevated_memory_usage.yml**: Memory utilization > 75% for 15 minutes  
**disk_space_warning.yml**: Disk usage > 70%  
**high_error_rate.yml**: Application error rate > 5%  
**slow_response_time.yml**: p95 latency > 1 second

### Info Alerts

**deployment_detected.yml**: New deployment detected  
**autoscaling_event.yml**: Auto Scaling group scaled  
**backup_completed.yml**: Automated backup completed

---

## 🔒 Security Best Practices

This monitoring stack follows AWS security best practices and implements defense-in-depth.

**Network Security:**
- Prometheus and AlertManager deployed in private subnets
- Grafana accessible via ALB in public subnets with SSL/TLS
- Security groups restrict access to necessary ports only
- VPC Flow Logs enabled for network monitoring

**Access Control:**
- IAM roles with least-privilege permissions
- Grafana authentication required for all access
- API keys rotated regularly
- MFA recommended for administrative access

**Data Protection:**
- EBS volumes encrypted at rest
- SSL/TLS for all external communication
- Sensitive credentials stored in AWS Secrets Manager
- CloudWatch Logs encrypted

**Monitoring & Audit:**
- CloudTrail logs all API calls
- CloudWatch Logs capture all application logs
- Failed authentication attempts trigger alerts
- Regular security scanning with AWS Inspector

---

## 💰 Cost Estimation

Running this monitoring stack incurs AWS costs that scale with infrastructure size.

**Estimated Monthly Costs (Small Deployment):**

| Service | Configuration | Estimated Cost |
|---------|---------------|----------------|
| EC2 (Prometheus) | t3.medium (2 vCPU, 4GB RAM) | $30.00 |
| EC2 (Grafana) | t3.small (2 vCPU, 2GB RAM) | $15.00 |
| EBS Volumes | 100 GB gp3 | $8.00 |
| ALB | 1 ALB with minimal traffic | $16.00 |
| CloudWatch Logs | 5 GB ingestion, 30-day retention | $2.50 |
| CloudWatch Metrics | 100 custom metrics | $30.00 |
| SNS | 1,000 notifications/month | $0.50 |
| Data Transfer | 10 GB outbound | $0.90 |
| **Total** | | **~$102.90/month** |

**Cost Optimization Tips:**
- Use Spot Instances for non-production environments (60-70% savings)
- Adjust metric retention periods based on requirements
- Right-size EC2 instances based on actual utilization
- Use CloudWatch Metric Streams for high-volume metrics
- Implement metric filtering to reduce unnecessary data

---

## 🧪 Testing

### Local Development with Docker Compose

Test the monitoring stack locally before deploying to AWS:

```bash
cd docker
docker-compose up -d

# Access services
Prometheus: http://localhost:9090
Grafana: http://localhost:3000
AlertManager: http://localhost:9093
```

### Terraform Validation

```bash
cd terraform/environments/dev

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# Security scanning
checkov -d .
tfsec .
```

---

## 📚 Documentation

Additional documentation is available in the `docs/` directory:

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Detailed architecture and design decisions
- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)**: Step-by-step deployment guide
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**: Common issues and solutions
- **[RUNBOOKS.md](docs/RUNBOOKS.md)**: Incident response procedures
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Guidelines for contributing

---

## 🤝 Contributing

Contributions are welcome! This is an educational project designed to help the community learn SRE and observability best practices.

**How to Contribute:**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-dashboard`)
3. Commit your changes (`git commit -m 'Add EC2 cost dashboard'`)
4. Push to the branch (`git push origin feature/new-dashboard`)
5. Open a Pull Request

Please ensure dashboards and configurations follow existing patterns and include documentation.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

This project was developed with AI assistance from Manus AI, Claude, Gemini, and other AI agents, demonstrating how experienced SRE and platform engineering leaders can leverage AI to accelerate observability implementation while maintaining strategic oversight and reliability engineering governance.

**Disclaimer:** This is a generic, educational example. All configurations, thresholds, and alert rules should be customized for your specific infrastructure and SLO requirements. No proprietary information or employer-specific content is included.

---

## 📫 Contact

**Author:** Mohamed Ben Lakhoua  
**LinkedIn:** [linkedin.com/in/benlakhoua](https://linkedin.com/in/benlakhoua)  
**Email:** mo@metafive.one  
**GitHub:** [github.com/mlakhoua-rgb](https://github.com/mlakhoua-rgb)

---

*This repository demonstrates AI-augmented SRE practices for AWS infrastructure monitoring. It showcases how platform engineering leaders can use AI agents as collaborators while maintaining human oversight of reliability engineering, incident response, and production stability.*

**Last Updated:** January 2026
