provider "aws" {
  allowed_account_ids = [var.account]
  region = var.infra_region
  version = "3.10.0"

  max_retries = 2
}
