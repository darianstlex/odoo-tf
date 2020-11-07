# We need a cluster in which to put our service.
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-cluster"
}

# Log groups hold logs from our app.
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ecs/${var.app_name}"
}
