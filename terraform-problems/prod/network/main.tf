# Production Network Module
# PROBLEM: Backend configuration is duplicated across all environments
# PROBLEM: Almost identical to dev/network/main.tf - code duplication!
terraform {
  backend "local" {
    path = "terraform-prod-network.tfstate"
  }
}

# Using local provider to create network configuration files
resource "local_file" "network_config" {
  filename = "${path.module}/outputs/network-config.json"
  content = jsonencode({
    environment = "prod"
    network_cidr = var.network_cidr
    subnet_count = var.subnet_count
    created_at = timestamp()
  })
}

# Simulate network resources with null_resource
resource "null_resource" "network" {
  triggers = {
    network_cidr = var.network_cidr
    environment = "prod"
  }
}
