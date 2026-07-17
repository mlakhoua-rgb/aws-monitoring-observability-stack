# Grafana Module Outputs

output "alb_dns_name" {
  description = "DNS name of the Grafana ALB"
  value       = aws_lb.grafana.dns_name
}

output "autoscaling_group_name" {
  description = "Name of the Grafana Auto Scaling Group"
  value       = aws_autoscaling_group.grafana.name
}
