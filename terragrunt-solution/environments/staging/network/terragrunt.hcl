# Staging Network Module Configuration

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
  environment  = "staging"
  network_cidr = "10.1.0.0/16"
  subnet_count = 3
}
