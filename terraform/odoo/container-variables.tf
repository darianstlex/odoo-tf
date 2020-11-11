variable "container_cpu" {
  description = "The number of cpu units used by the task"
  default = 2048
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default = 4096
}

variable "container_app_port" {
  description = "The port where the Docker is exposed"
  default = 8069
}

variable "container_app_image" {
  description = "App docker image"
  default = "odoo:latest"
}

variable "container_db_image" {
  description = "App docker image"
  default = "postgres:10"
}

variable db_username {
  description = "DB username"
  default = "odoo"
}

variable db_password {
  description = "DB password"
  default = "odoo"
}
