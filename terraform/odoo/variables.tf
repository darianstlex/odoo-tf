variable terraform_version {
  type = string
  default = ">= 0.13.0, < 0.14.0"
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

variable "environment" {
  description = "The name of your environment"
  default = "production"
}

variable "availability_zones" {
  description = "A comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "A list of CIDRs for private subnets in your VPC"
  default = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "public_subnets" {
  description = "A list of CIDRs for public subnets in your VPC,"
  default = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
}

variable "service_desired_count" {
  description = "Number of tasks running in parallel"
  default = 1
}

variable "health_check_path" {
  description = "HTTP path for task health check"
  default = "/health"
}

variable "application_secrets" {
  description = "A map of secrets that is passed into the application. Formatted like ENV_VAR = VALUE"
}
