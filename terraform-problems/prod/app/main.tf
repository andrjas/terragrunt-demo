# Production Application Module
# PROBLEM: Backend configuration is duplicated
# PROBLEM: Almost identical to dev/app/main.tf - code duplication!
terraform {
  backend "local" {
    path = "terraform-prod-app.tfstate"
  }
}

# PROBLEM: No automatic dependency management
# We need to manually pass network outputs or use data sources
variable "network_cidr" {
  description = "Network CIDR - must be manually copied from network module"
  type        = string
}

# Using local provider to create app configuration
resource "local_file" "app_config" {
  filename = "${path.module}/outputs/app-config.json"
  content = jsonencode({
    environment = "prod"
    app_name = var.app_name
    replicas = var.replicas
    network_cidr = var.network_cidr
    created_at = timestamp()
  })
}

# Simulate application deployment
resource "null_resource" "app" {
  triggers = {
    app_name = var.app_name
    environment = "prod"
    replicas = var.replicas
  }
}
