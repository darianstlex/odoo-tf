resource "local_file" "variables_file_odoo" {
  file_permission = "0600"
  content = <<FILE
variable "aws_account" {
  type = string
  description = "aws account - env variable"
}

variable "aws_region" {
  type = string
  description = "aws region - env variable"
}

variable "stack_name" {
  type = string
  description = "stack name - env variable"
}
FILE
  filename = "${path.root}/../${var.stack_name}/variables.tf"
}
