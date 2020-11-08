resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-cluster"
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ecs/${var.app_name}"
}
