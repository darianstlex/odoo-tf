locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect: "Allow"
        Sid: ""
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.stack_name}-ecs-task-execution-role"
  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.stack_name}-ecs-task-role"
  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.stack_name}-cluster-${var.environment}"
  tags = {
    Name = "${var.stack_name}-cluster-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "main" {
  name = "${var.stack_name}-service-${var.environment}"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count = var.service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
  health_check_grace_period_seconds = 60
  launch_type = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    security_groups = [
      aws_security_group.ecs_tasks.id,
      aws_security_group.file_system.id
    ]
    subnets = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name = "${var.stack_name}-container-${var.environment}"
    container_port = var.container_app_port
  }

//  lifecycle {
//    ignore_changes = [task_definition, desired_count]
//  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity = 1
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name = "memory-autoscaling"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
    scale_in_cooldown = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name = "cpu-autoscaling"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
    scale_in_cooldown = 300
    scale_out_cooldown = 300
  }
}
