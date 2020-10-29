resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-${var.account}-${var.infra_region}"

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "tflocks" {
  name         = "tflock-${var.account}-${var.infra_region}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


#------------------------------------------------------
# GENERATED FOR THE INFRA BUILD ORCHESTRATED LATER ON
#------------------------------------------------------
resource "local_file" "state_file_odoo" {
  file_permission = "0600"
  content = <<FILE
terraform {
  backend "s3" {
    region         = "${aws_s3_bucket.tfstate.region}"
    bucket         = "${aws_s3_bucket.tfstate.id}"
    dynamodb_table = "${aws_dynamodb_table.tflocks.id}"
    encrypt        = true
    key            = "${var.infra_region}/${var.infra_stack}/terraform.tfstate"
  }
}
FILE
  filename = "${path.module}/../odoo/state.tf"
}

resource "local_file" "provider_file_odoo" {
  file_permission = "0600"
  content = <<FILE
provider "aws" {
  allowed_account_ids = [var.account]
  region = var.infra_region
  version = "${var.aws_provider_version}"

  max_retries = 2
}
FILE
  filename = "${path.module}/../odoo/provider.tf"
}

resource "local_file" "versions_file_odoo" {
  file_permission = "0600"
  content = <<FILE
terraform {
  required_version = "${var.terraform_version}"
}
FILE
  filename = "${path.module}/../odoo/versions.tf"
}

resource "local_file" "variables_file_odoo" {
  file_permission = "0600"
  content = <<FILE
variable "infra_region" {
  type    = string
  default = "${var.infra_region}"
}

variable "infra_stack" {
  type    = string
  default = "${var.infra_stack}"
}

variable "account" {
  type    = string
  default = "${var.account}"
}

variable "aws_provider_version" {
  type    = string
  default = "${var.aws_provider_version}"
}
FILE
  filename = "${path.module}/../odoo/variables.tf"
}


#------------------------------------------------------
# OUTPUTS
#------------------------------------------------------
output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.arn
}

output "tflocks_table" {
  value = aws_dynamodb_table.tflocks.arn
}
