# Dev Environment Configuration
# SOLUTION: Environment-specific values defined once

# Include the root terragrunt.hcl configuration
include "root" {
  path = find_in_parent_folders()
}

# Common inputs for all modules in dev environment
inputs = {
  environment = "dev"
}
