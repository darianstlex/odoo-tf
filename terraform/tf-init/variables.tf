variable terraform_version {
  type = string
  default = ">= 0.13.0, < 0.14.0"
}

variable aws_provider_version {
  type = string
  description = "aws provider version - env variable"
  default = "3.10.0"
}

variable aws_account {
  type = string
  description = "aws account - env variable"
}

variable aws_region {
  type = string
  description = "aws region - env variable"
}

variable stack_name {
  type = string
  description = "stack name - env variable"
}
