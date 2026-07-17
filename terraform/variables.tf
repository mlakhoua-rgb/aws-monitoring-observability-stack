# AWS Monitoring & Observability Stack - Terraform Variables

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "aws-monitoring-stack"
}

variable "vpc_id" {
  description = "ID of the VPC to deploy into"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for deployment"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "prometheus_instance_type" {
  description = "EC2 instance type for Prometheus server"
  type        = string
  default     = "t3.medium"
}

variable "grafana_instance_type" {
  description = "EC2 instance type for Grafana servers"
  type        = string
  default     = "t3.small"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana dashboard"
  type        = string
  sensitive   = true
}

variable "alb_allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the Grafana ALB on port 80. Grafana's own login still applies; restrict to office/VPN ranges where possible."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "trusted_cidr_blocks" {
  description = "List of trusted CIDR blocks allowed to access Prometheus (port 9090) and Grafana (port 3000). Should be your VPC CIDR, VPN CIDR, or bastion host IP. Never use 0.0.0.0/0 in production."
  type        = list(string)
  # Example: ["10.0.0.0/8", "172.16.0.0/12"] for private networks
  # Override in terraform.tfvars or via -var flag
  default = ["10.0.0.0/8"]
}
