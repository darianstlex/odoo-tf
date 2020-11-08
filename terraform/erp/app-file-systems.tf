resource "aws_efs_file_system" "app_fs" {
  creation_token = "${var.app_name}-file-system"
}

resource "aws_efs_access_point" "app_fs" {
  file_system_id = aws_efs_file_system.app_fs.id
  root_directory {
    path = "/extra-addons"
  }
}

resource "aws_efs_access_point" "app_db_fs" {
  file_system_id = aws_efs_file_system.app_fs.id
  root_directory {
    path = "/database"
  }
}

resource "aws_efs_mount_target" "app_fs_mt" {
  count = length(data.aws_availability_zones.aws_az.names)
  file_system_id = aws_efs_file_system.app_fs.id
  subnet_id      = aws_subnet.aws_subnet[count.index].id
  security_groups = [aws_security_group.app_fs_sg.id]
}
