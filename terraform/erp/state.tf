terraform {
  backend s3 {
    region = "eu-west-1"
    bucket = "tfstate-888355548218-eu-west-1"
    dynamodb_table = "tflock-888355548218-eu-west-1"
    encrypt = true
    key = "eu-west-1/erp/terraform.tfstate"
  }
}
