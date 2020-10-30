module vpc {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.vpc_name}-${var.stack_name}"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

output vpc_id {
  value = "module.vpc.vpc_id"
}

resource aws_security_group lb {
  name        = "${var.stack_name}-lb-sg"
  description = "Controls access to the Application Load Balancer (ALB)"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_security_group ecs_tasks {
  name        = "${var.stack_name}-ecs-tasks-sg"
  description = "Allow inbound access from the ALB only"

  ingress {
    protocol        = "tcp"
    from_port       = 4000
    to_port         = 4000
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_lb public_lb {
  name               = "${var.stack_name}-alb"
  subnets            = module.vpc.public_subnets
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
}

resource aws_lb_target_group public_lb_tg {
  name        = "${var.stack_name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource aws_lb_listener https_forward {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_lb_tg.arn
  }
}
