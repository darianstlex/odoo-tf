resource "local_file" "provider_file" {
  file_permission = "0600"
  content = <<FILE
provider "aws" {
  allowed_account_ids = [var.aws_account]
  region = var.aws_region
  version = "${var.aws_provider_version}"
  max_retries = 2
}
FILE
  filename = "${path.root}/../${var.stack_name}/provider.tf"
}
