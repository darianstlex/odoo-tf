variable app_name {
  description = "Application Name"
  default = "odoo"
}

variable app_port {
  description = "Application Port"
  default = 8069
}

variable app_image {
  description = "Application Image"
  default = "odoo:latest"
}

variable db_username {
  description = "postgres db username"
  default = "odoo"
}

variable db_password {
  description = "postgres db password"
  default = "Passw0rd1!"
}

variable app_cpu {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default = "1024"
}

variable app_memory {
  description = "Fargate instance memory to provision (in MiB)"
  default = "2048"
}
