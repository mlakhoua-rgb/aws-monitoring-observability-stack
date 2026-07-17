# Prometheus Terraform Module
#
# Single-node Prometheus on EC2 (Docker), with EC2 service discovery for
# node-exporter targets tagged Monitoring=enabled. Deliberately not HA —
# for durable/HA metrics pair this with remote_write to Amazon Managed
# Prometheus or Thanos (see docs/ARCHITECTURE.md, "Deliberate limitations").

resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = var.security_group_ids

  root_block_device {
    volume_size = var.root_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  # Writes the Prometheus config before starting the container — the config
  # must exist on the host or the bind mount silently becomes an empty
  # directory and Prometheus starts with no scrape targets.
  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker

    mkdir -p /etc/prometheus
    cat > /etc/prometheus/prometheus.yml <<'PROM'
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
      external_labels:
        cluster: 'aws'
        environment: '${var.environment}'

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      - job_name: 'node-exporter'
        ec2_sd_configs:
          - region: ${var.aws_region}
            port: 9100
            filters:
              - name: tag:Monitoring
                values: [enabled]
              - name: instance-state-name
                values: [running]
        relabel_configs:
          - source_labels: [__meta_ec2_instance_id]
            target_label: instance
          - source_labels: [__meta_ec2_tag_Environment]
            target_label: environment
          - source_labels: [__meta_ec2_tag_Service]
            target_label: service
    PROM

    docker run -d --name prometheus \
      --restart unless-stopped \
      -p 9090:9090 \
      -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
      -v prometheus_data:/prometheus \
      prom/prometheus:v2.45.0 \
      --config.file=/etc/prometheus/prometheus.yml \
      --storage.tsdb.path=/prometheus \
      --storage.tsdb.retention.time=${var.retention_days}d
  EOF

  user_data_replace_on_change = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-prometheus" })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
