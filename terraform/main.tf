# AWS Monitoring & Observability Stack — Main Terraform Configuration
# License: MIT

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Recommended backend — uncomment and configure for team use
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "monitoring/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-monitoring-stack"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  common_tags = {
    Project     = "aws-monitoring-stack"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# Security groups — traffic flows ALB → Grafana → Prometheus
# ---------------------------------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Internet-facing ALB for Grafana"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP to Grafana (Grafana login still applies)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-alb-sg" })
}

resource "aws_security_group" "grafana" {
  name        = "${var.project_name}-grafana-sg"
  description = "Grafana instances — reachable only through the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Grafana port from the ALB only"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-grafana-sg" })
}

resource "aws_security_group" "prometheus" {
  name        = "${var.project_name}-prometheus-sg"
  description = "Prometheus server — internal access only"
  vpc_id      = var.vpc_id

  # Operator access (VPN / bastion / VPC CIDR)
  ingress {
    description = "Prometheus UI/API from trusted CIDRs"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.trusted_cidr_blocks
  }

  # Grafana queries Prometheus as its datasource
  ingress {
    description     = "Prometheus API from Grafana"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.grafana.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.project_name}-prometheus-sg" })
}

# ---------------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------------

resource "aws_iam_role" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_instance_profile.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Prometheus EC2 service discovery needs read-only instance metadata.
resource "aws_iam_role_policy" "prometheus_sd" {
  name = "${var.project_name}-prometheus-sd"
  role = aws_iam_role.ec2_instance_profile.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "PrometheusEC2ServiceDiscovery"
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeAvailabilityZones"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_instance_profile.name
}

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------

module "prometheus" {
  source = "./modules/prometheus"

  project_name         = var.project_name
  environment          = var.environment
  aws_region           = var.aws_region
  vpc_id               = var.vpc_id
  subnet_id            = var.private_subnet_ids[0]
  instance_type        = var.prometheus_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_group_ids   = [aws_security_group.prometheus.id]
  common_tags          = local.common_tags
}

module "grafana" {
  source = "./modules/grafana"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = var.vpc_id
  subnet_ids            = var.private_subnet_ids
  alb_subnet_ids        = var.public_subnet_ids
  alb_security_group_id = aws_security_group.alb.id
  instance_type         = var.grafana_instance_type
  iam_instance_profile  = aws_iam_instance_profile.ec2_profile.name
  security_group_ids    = [aws_security_group.grafana.id]
  admin_password        = var.grafana_admin_password
  prometheus_endpoint   = "http://${module.prometheus.private_ip}:9090"
  common_tags           = local.common_tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "prometheus_private_ip" {
  description = "Private IP of the Prometheus server"
  value       = module.prometheus.private_ip
}

output "grafana_url" {
  description = "Grafana dashboard URL (via ALB)"
  value       = "http://${module.grafana.alb_dns_name}"
}
