resource "aws_security_group" "alb" {
  name   = "${var.stack_name}-alb-sg-${var.environment}"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "TCP"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "TCP"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stack_name}-alb-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${var.stack_name}-ecs-task-sg-${var.environment}"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    from_port = var.container_app_port
    to_port = var.container_app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.stack_name}-ecs-task-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "file_system" {
  name = "${var.stack_name}-file-system-sg"
  description = "Allow fs ingress / egress"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  egress {
    from_port = 2049
    to_port = 2049
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  tags = {
    Name = "${var.stack_name}-file-system-sg-${var.environment}"
    Environment = var.environment
  }
}
