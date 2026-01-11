# Grafana Terraform Module

resource "aws_launch_configuration" "grafana" {
  name_prefix   = "${var.project_name}-grafana-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  security_groups = var.security_group_ids

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo docker run -d --name grafana -p 3000:3000 \
                -e "GF_SECURITY_ADMIN_PASSWORD=${var.admin_password}" \
                -e "GF_DATASOURCES_DEFAULT_PROMETHEUS_URL=${var.prometheus_endpoint}" \
                grafana/grafana
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "grafana" {
  name                 = "${var.project_name}-grafana-asg"
  launch_configuration = aws_launch_configuration.grafana.name
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  vpc_zone_identifier  = var.subnet_ids

  tag {
    key                 = "Name"
    value               = "${var.project_name}-grafana"
    propagate_at_launch = true
  }
}

resource "aws_lb" "grafana" {
  name               = "${var.project_name}-grafana-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "grafana" {
  name     = "${var.project_name}-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_autoscaling_attachment" "grafana" {
  autoscaling_group_name = aws_autoscaling_group.grafana.id
  lb_target_group_arn    = aws_lb_target_group.grafana.arn
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

output "alb_dns_name" {
  value = aws_lb.grafana.dns_name
}
