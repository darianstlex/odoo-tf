provider aws {
  allowed_account_ids = [var.aws_account]
  region = var.aws_region

  max_retries = 2
}
