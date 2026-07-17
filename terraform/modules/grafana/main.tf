# Grafana Terraform Module
#
# Grafana in an Auto Scaling Group behind an internet-facing ALB.
# The Prometheus datasource is provisioned via a file written in user_data —
# Grafana has no GF_DATASOURCES_* environment variables; provisioning files
# are the supported mechanism.

resource "aws_launch_template" "grafana" {
  name_prefix   = "${var.project_name}-grafana-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = var.security_group_ids

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euo pipefail
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker

    mkdir -p /etc/grafana/provisioning/datasources
    cat > /etc/grafana/provisioning/datasources/prometheus.yml <<DS
    apiVersion: 1
    datasources:
      - name: Prometheus
        uid: prometheus
        type: prometheus
        access: proxy
        url: ${var.prometheus_endpoint}
        isDefault: true
    DS

    docker run -d --name grafana \
      --restart unless-stopped \
      -p 3000:3000 \
      -e "GF_SECURITY_ADMIN_PASSWORD=${var.admin_password}" \
      -e "GF_USERS_ALLOW_SIGN_UP=false" \
      -v /etc/grafana/provisioning:/etc/grafana/provisioning:ro \
      -v grafana_data:/var/lib/grafana \
      grafana/grafana:10.0.0
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.common_tags, { Name = "${var.project_name}-grafana" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "grafana" {
  name                = "${var.project_name}-grafana-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = var.subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.grafana.arn]

  launch_template {
    id      = aws_launch_template.grafana.id
    version = "$Latest"
  }

  # Roll instances when the launch template changes — without this, an
  # existing instance keeps the old Prometheus datasource URL baked into its
  # user_data after a Prometheus replacement ($Latest only affects future
  # launches). 100% min healthy = launch the replacement before terminating
  # (max_size leaves headroom for it).
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
  }

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
  security_groups    = [var.alb_security_group_id]
  subnets            = var.alb_subnet_ids

  tags = var.common_tags
}

resource "aws_lb_target_group" "grafana" {
  name     = "${var.project_name}-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Grafana's / redirects to /login (302), which fails the default health
  # check — /api/health returns a plain 200.
  health_check {
    path                = "/api/health"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = var.common_tags
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
