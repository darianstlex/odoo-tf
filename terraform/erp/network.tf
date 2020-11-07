# Network Setup: VPC, Subnet, IGW, Routes | network.tf
data "aws_availability_zones" "aws_az" {
  state = "available"
}

# create vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

# create subnets
resource "aws_subnet" "aws_subnet" {
  count = 3
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.aws_az.names[count.index]
  map_public_ip_on_launch = true
}

# create internet gateway
resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.vpc.id
}

# create routes
resource "aws_route_table" "aws_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }
}

resource "aws_main_route_table_association" "aws_route_table_association" {
  vpc_id = aws_vpc.vpc.id
  route_table_id = aws_route_table.aws_route_table.id
}

resource "aws_alb" "lb" {
  name               = "${var.app_name}-load-balancer"
  internal           = false
  load_balancer_type = "application"

  subnets = aws_subnet.aws_subnet.*.id

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.rds_sg.id,
    aws_security_group.egress-all.id
  ]

  depends_on = [aws_internet_gateway.aws_igw]
}

resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.app_name}-load-balancer-target-group"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    path = "/web/static/src/img/logo2.png"
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }

  depends_on = [aws_alb.lb]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.lb.dns_name}"
}

resource "aws_acm_certificate" "app" {
  domain_name       = "ipuit.tech"
  validation_method = "DNS"
}

output "domain_validations" {
  value = aws_acm_certificate.app.domain_validation_options
}
