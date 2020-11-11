resource "aws_alb" "main" {
  name = "${var.stack_name}-alb-${var.environment}"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = aws_subnet.public.*.id

  enable_deletion_protection = false

  tags = {
    Name = "${var.stack_name}-alb-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "main" {
  name = "${var.stack_name}-alb-tg-${var.environment}"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    interval = "30"
    protocol = "HTTP"
    matcher = "200"
    timeout = "3"
    path = var.health_check_path
    unhealthy_threshold = "2"
  }

  depends_on = [aws_alb.main]

  tags = {
    Name = "${var.stack_name}-alb-tg-${var.environment}"
    Environment = var.environment
  }
}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.id
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Redirect traffic to target group
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port = 443
  protocol = "HTTPS"

  certificate_arn = aws_acm_certificate.app.arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type = "forward"
  }
}

output "alb_url" {
  value = "http://${aws_alb.main.dns_name}"
}
