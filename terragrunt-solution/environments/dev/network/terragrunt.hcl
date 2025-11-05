# Dev Network Module Configuration

# Include the environment-specific configuration
include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

# Point to the shared network module
terraform {
  source = "../../../modules/network"
}

# Module-specific inputs
inputs = {
  network_cidr = "10.0.0.0/16"
  subnet_count = 2
}
