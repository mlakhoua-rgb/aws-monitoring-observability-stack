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

variable "alert_email" {
  description = "Email address for AlertManager notifications"
  type        = string
  default     = ""
}
