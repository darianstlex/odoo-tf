resource "aws_security_group" "http_sg" {
  name        = "${var.app_name}-http-sg"
  description = "HTTP traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "egress_all_sg" {
  name        = "${var.app_name}-egress-all-sg"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_sg" {
  name        = "${var.app_name}-app-ingress-sg"
  description = "Allow ingress to APP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 8069
    to_port     = 8069
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_fs_sg" {
  name        = "${var.app_name}-app-fs-sg"
  description = "Allow ingress to fs"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    self = true
  }
}
