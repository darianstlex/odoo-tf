resource "aws_ecs_task_definition" "main" {
  family = "${var.stack_name}-task-${var.environment}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.container_cpu
  memory = var.container_memory
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  volume {
    name = "app-fs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.file_system.id
      root_directory = "/extra-addons"
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.app_fs.id
      }
    }
  }

//  volume {
//    name = "db-fs"
//    efs_volume_configuration {
//      file_system_id = aws_efs_file_system.file_system.id
//      root_directory = "/database"
//      transit_encryption = "ENABLED"
//
//      authorization_config {
//        access_point_id = aws_efs_access_point.db_fs.id
//      }
//    }
//  }

  container_definitions = jsonencode([{
    name = "${var.stack_name}-container-${var.environment}"
    image = var.container_app_image
    essential = true
    portMappings = [{
      containerPort = var.container_app_port
    }]
    dependsOn = [{
      containerName = "${var.stack_name}-db-container-${var.environment}"
      condition = "START"
    }]
    environment = [{
      name = "HOST"
      value = "127.0.0.1"
    }]
    mountPoints = [{
      sourceVolume = "app-fs"
      containerPath = "/mnt/extra-addons"
      readOnly = true
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.main.name
        awslogs-stream-prefix = "ecs"
        awslogs-region = var.aws_region
      }
    }
  },{
    name = "${var.stack_name}-db-container-${var.environment}"
    image = var.container_db_image
    essential = false
    environment = [{
      name = "POSTGRES_DB"
      value = "postgres"
    },{
      name = "POSTGRES_USER"
      value = var.db_username
    },{
      name = "POSTGRES_PASSWORD"
      value = var.db_password
    }]
//    mountPoints = [{
//      sourceVolume = "db-fs"
//      containerPath = "/var/lib/postgresql/data"
//      readOnly = false
//    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = aws_cloudwatch_log_group.main.name
        awslogs-stream-prefix = "ecs"
        awslogs-region = var.aws_region
      }
    }
  }])

  tags = {
    Name = "${var.stack_name}-task-${var.environment}"
    Environment = var.environment
  }
}
