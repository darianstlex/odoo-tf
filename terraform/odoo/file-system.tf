resource "aws_efs_file_system" "file_system" {
  creation_token = "${var.stack_name}-file-system"

  tags = {
    Name = "${var.stack_name}-file-system-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_access_point" "app_fs" {
  file_system_id = aws_efs_file_system.file_system.id
  root_directory {
    path = "/extra-addons"
  }

  tags = {
    Name = "${var.stack_name}-app-fs-access-point-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_access_point" "db_fs" {
  file_system_id = aws_efs_file_system.file_system.id
  root_directory {
    path = "/database"
  }

  tags = {
    Name = "${var.stack_name}-db-fs-access-point-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "file_system" {
  count = length(var.availability_zones)
  file_system_id = aws_efs_file_system.file_system.id
  subnet_id = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.file_system.id]
}
