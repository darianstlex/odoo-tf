resource "local_file" "versions_file" {
  file_permission = "0600"
  content = <<FILE
terraform {
  required_version = "${var.terraform_version}"
}
FILE
  filename = "${path.root}/../${var.stack_name}/versions.tf"
}
