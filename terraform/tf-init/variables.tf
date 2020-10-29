variable "terraform_version" {
  type    = string
  default = ">= 0.13.2, < 0.14.0"
}

variable "aws_provider_version" {
  type    = string
  default = "3.10.0"
}

variable "infra_region" {
  type    = string
  default = "eu-west-1"
}

variable "infra_stack" {
  type    = string
  default = "odoo"
}

variable "account" {
  type    = string
  default = "508064002655"
}
