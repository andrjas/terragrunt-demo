# Staging Network Module
# PROBLEM: Backend configuration is duplicated across all environments
# PROBLEM: Almost identical to dev/network/main.tf - code duplication!
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
    path = "terraform-staging-network.tfstate"
  }
}

# Using local provider to create network configuration files
resource "local_file" "network_config" {
  filename        = "${path.module}/network-config.json"
  content = jsonencode({
    environment  = "staging"
    network_cidr = var.network_cidr
    subnet_count = var.subnet_count
  })
  file_permission = "0644"
}

# Simulate network resources with null_resource
resource "null_resource" "network" {
  triggers = {
    network_cidr = var.network_cidr
    environment = "staging"
  }
}
