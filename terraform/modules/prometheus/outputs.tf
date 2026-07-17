# Prometheus Module Outputs

output "private_ip" {
  description = "Private IP of the Prometheus server"
  value       = aws_instance.prometheus.private_ip
}

output "instance_id" {
  description = "Instance ID of the Prometheus server"
  value       = aws_instance.prometheus.id
}
