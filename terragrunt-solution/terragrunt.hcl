# Root Terragrunt Configuration
# This file contains settings that are shared across all environments

# Configure the backend
# SOLUTION: Backend configuration is defined once and reused everywhere!
remote_state {
  backend = "local"

  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
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
}
EOF
}

# Common inputs that can be used across all modules
inputs = {
  # These can be overridden in environment-specific configs
}
