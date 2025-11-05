# Production Network Module Configuration

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
  environment  = "prod"
  network_cidr = "10.2.0.0/16"
  subnet_count = 4
}
