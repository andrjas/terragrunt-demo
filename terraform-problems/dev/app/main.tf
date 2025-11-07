# Dev Application Module
# PROBLEM: Backend configuration is duplicated
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  backend "local" {
    path = "terraform-dev-app.tfstate"
  }
}

# PROBLEM: No automatic dependency management
# We need to manually pass network outputs or use data sources

# Using local provider to create app configuration
resource "local_file" "app_config" {
  filename        = "${path.module}/app-config.json"
  content = jsonencode({
    environment  = "dev"
    app_name     = var.app_name
    replicas     = var.replicas
    network_cidr = var.network_cidr
  })
  file_permission = "0644"
}

# Simulate application deployment
resource "null_resource" "app" {
  triggers = {
    app_name = var.app_name
    environment = "dev"
    replicas = var.replicas
  }
}
