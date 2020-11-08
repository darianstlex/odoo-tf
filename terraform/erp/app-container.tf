resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-ecs-service"
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  cluster         = aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"
  platform_version = "1.4.0"

  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }

  network_configuration {
    assign_public_ip = true

    security_groups = [
      aws_security_group.egress_all_sg.id,
      aws_security_group.ingress_sg.id,
      aws_security_group.app_fs_sg.id
//      aws_security_group.db_access_sg.id
    ]

    subnets = aws_subnet.aws_subnet.*.id
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.app_name}-task-definition"

  volume {
    name = "app-fs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.app_fs.id
      root_directory = "/extra-addons"
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.app_fs.id
      }
    }
  }

  volume {
    name = "db-fs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.app_fs.id
      root_directory = "/database"
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.app_db_fs.id
      }
    }
  }

  container_definitions = <<EOF
[
  {
    "name": "odoo",
    "image": "${var.app_image}",
    "cpu": ${var.app_cpu},
    "memory": ${var.app_memory},
    "dependsOn": [
      {
        "containerName": "db",
        "condition": "START"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "HOST",
        "value": "127.0.0.1"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${var.app_port}
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "app-fs",
        "containerPath": "/mnt/extra-addons",
        "readOnly": true
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.aws_region}",
        "awslogs-group": "/ecs/${var.app_name}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  },
  {
    "name": "db",
    "image": "postgres:10",
    "cpu": ${var.app_cpu},
    "memory": ${var.app_memory},
    "essential": false,
    "environment": [
      {
        "name": "POSTGRES_DB",
        "value": "postgres"
      },
      {
        "name": "POSTGRES_USER",
        "value": "${var.db_username}"
      },
      {
        "name": "POSTGRES_PASSWORD",
        "value": "${var.db_password}"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "db-fs",
        "containerPath": "/var/lib/postgresql/data",
        "readOnly": false
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.aws_region}",
        "awslogs-group": "/ecs/${var.app_name}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
}
