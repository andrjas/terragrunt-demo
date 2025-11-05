# Dev Network Module Configuration

# Include the root terragrunt configuration
include "root" {
  path = "../../../terragrunt.hcl"
}

# Point to the shared network module
terraform {
  source = "../../../modules/network"
}

# Module-specific inputs
inputs = {
  environment  = "dev"
  network_cidr = "10.0.0.0/16"
  subnet_count = 2
}
