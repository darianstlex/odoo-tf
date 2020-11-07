# The main service.
resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-ecs-service"
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  cluster         = aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"

  desired_count = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }

  network_configuration {
    assign_public_ip = true

    security_groups = [
      aws_security_group.egress-all.id,
      aws_security_group.ingress.id,
      aws_security_group.db_access_sg.id
    ]

    subnets = aws_subnet.aws_subnet.*.id
  }
}

# The task definition for our app.
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "${var.app_name}-task-definition"

  container_definitions = <<EOF
[
  {
    "name": "odoo",
    "image": "${var.app_image}",
    "cpu": ${var.app_cpu},
    "memory": ${var.app_memory},
    "environment": [
      {
        "name": "${aws_db_instance.rds.address}",
        "value": "127.0.0.1"
      },
      {
        "name": "USER",
        "value": "${var.db_username}"
      },
      {
        "name": "PASSWORD",
        "value": "${var.db_password}"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${var.app_port}
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

  # These are the minimum values for Fargate containers.
  cpu                      = 1024
  memory                   = 2048
  requires_compatibilities = ["FARGATE"]

  # This is required for Fargate containers (more on this later).
  network_mode = "awsvpc"
}
