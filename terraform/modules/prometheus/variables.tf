# Prometheus Module Variables

variable "project_name" {
  description = "Project name used as a prefix for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "Region used by the EC2 service-discovery configuration"
  type        = string
}

variable "vpc_id" {
  description = "VPC to deploy into"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet for the Prometheus instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Prometheus server"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GiB (holds the Prometheus TSDB)"
  type        = number
  default     = 50
}

variable "retention_days" {
  description = "Prometheus TSDB retention in days"
  type        = number
  default     = 15
}

variable "iam_instance_profile" {
  description = "Instance profile name (needs ec2:DescribeInstances for service discovery)"
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the instance"
  type        = list(string)
}

variable "common_tags" {
  description = "Tags applied to all module resources"
  type        = map(string)
  default     = {}
}
