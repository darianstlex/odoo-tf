resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-${var.aws_account}-${var.aws_region}"

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
  name = "tflock-${var.aws_account}-${var.aws_region}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


#------------------------------------------------------
# GENERATED FOR THE INFRA BUILD ORCHESTRATED LATER ON
#------------------------------------------------------
module "state_file" {
  source = "./modules/state_file"
  aws_region = var.aws_region
  stack_name = var.stack_name
  bucket_id = aws_s3_bucket.tfstate.id
  bucket_region = aws_s3_bucket.tfstate.region
  dynamodb_table_id = aws_dynamodb_table.tflocks.id
}

module "provider_file" {
  source = "./modules/provider_file"
  aws_provider_version = var.aws_provider_version
  aws_account = var.aws_account
  aws_region = var.aws_region
  stack_name = var.stack_name
}

module "versions_file" {
  source = "./modules/versions_file"
  terraform_version = var.terraform_version
  stack_name = var.stack_name
}

module "variables_file" {
  source = "./modules/variables_file"
  stack_name = var.stack_name
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
