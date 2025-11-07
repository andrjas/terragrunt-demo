# Staging App Module Configuration

# Include the root terragrunt configuration
include "root" {
  path = "../../../terragrunt.hcl"
}

# Point to the shared app module
terraform {
  source = "../../../modules/app"
}

# SOLUTION: Automatic dependency management!
# Terragrunt will ensure network is applied before app
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    network_cidr = "10.1.0.0/16"
    network_id   = "mock-network-id"
  }
}

# Module-specific inputs
inputs = {
  environment  = "staging"
  app_name     = "demo-app"
  replicas     = 3
  # SOLUTION: Automatically use output from network module - no manual copying!
  network_cidr = dependency.network.outputs.network_cidr
}
