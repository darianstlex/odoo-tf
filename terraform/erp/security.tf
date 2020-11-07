resource "aws_security_group" "http" {
  name        = "${var.app_name}-http"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress-all" {
  name        = "${var.app_name}-egress-all"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress" {
  name        = "${var.app_name}-app-ingress"
  description = "Allow ingress to APP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 8069
    to_port     = 8069
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
