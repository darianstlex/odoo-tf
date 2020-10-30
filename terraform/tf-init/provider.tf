provider "aws" {
  allowed_account_ids = [var.aws_account]
  region = var.aws_region
  version = "3.10.0"

  max_retries = 2
}
