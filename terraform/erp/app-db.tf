/* subnet used by rds */
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.app_name}-rds-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = aws_subnet.aws_subnet.*.id
}

/* Security Group for resources that want to access the Database */
resource "aws_security_group" "db_access_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.app_name}-db-access-sg"
  description = "Allow access to RDS"
}

resource "aws_security_group" "rds_sg" {
  name = "${var.app_name}-rds-sg"
  description = "${var.app_name} security group"
  vpc_id = aws_vpc.vpc.id

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  //allow traffic for TCP 5432
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [aws_security_group.db_access_sg.id]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds" {
  identifier             = "${var.app_name}-database"
  allocated_storage      = "5"
  engine                 = "postgres"
  engine_version         = "10"
  instance_class         = "db.t2.micro"
  name                   = var.app_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
//  snapshot_identifier    = "rds-${var.app_name}-snapshot"
}
