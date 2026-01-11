# Prometheus Terraform Module

resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  iam_instance_profile = var.iam_instance_profile
  vpc_security_group_ids = var.security_group_ids

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker run -d --name prometheus -p 9090:9090 \
                -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
                prom/prometheus
              EOF

  tags = merge(var.common_tags, { Name = "${var.project_name}-prometheus" })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

output "private_ip" {
  value = aws_instance.prometheus.private_ip
}

output "public_ip" {
  value = aws_instance.prometheus.public_ip
}
