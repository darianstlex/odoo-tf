variable "terraform_version" {
  type    = string
  default = ">= 0.12.0, < 0.14.0"
}

variable "aws_provider_version" {
  type    = string
  default = "3.10.0"
}

variable "infra_region" {
  type    = string
  default = "eu-west-1"
  description = "AWS region"
}

variable "infra_stack" {
  type    = string
  default = "test_stack"
  description = "Stack name"
}

variable "account" {
  type    = string
  default = "000000000000"
  description = "AWS account id used for deployment"
}
