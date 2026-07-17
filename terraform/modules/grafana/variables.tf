# Grafana Module Variables

variable "project_name" {
  description = "Project name used as a prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC to deploy into"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets for the Grafana instances (Auto Scaling Group)"
  type        = list(string)
}

variable "alb_subnet_ids" {
  description = "Public subnets for the internet-facing ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group for the ALB"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Grafana"
  type        = string
  default     = "t3.small"
}

variable "iam_instance_profile" {
  description = "Instance profile name for the Grafana instances"
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the Grafana instances"
  type        = list(string)
}

variable "admin_password" {
  description = "Grafana admin password. Note: passed via user_data, so it is visible to anyone who can read launch template versions — use a dedicated password and prefer SSO/OAuth beyond a demo."
  type        = string
  sensitive   = true
}

variable "prometheus_endpoint" {
  description = "URL of the Prometheus server used as the default datasource"
  type        = string
}

variable "common_tags" {
  description = "Tags applied to all module resources"
  type        = map(string)
  default     = {}
}
