resource "local_file" "state_file" {
  file_permission = "0600"
  content = <<FILE
terraform {
  backend "s3" {
    region = "${var.bucket_region}"
    bucket = "${var.bucket_id}"
    dynamodb_table = "${var.dynamodb_table_id}"
    encrypt = true
    key = "${var.aws_region}/${var.stack_name}/terraform.tfstate"
  }
}
FILE
  filename = "${path.root}/../${var.stack_name}/state.tf"
}
