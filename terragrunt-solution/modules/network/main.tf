# Shared Network Module
# SOLUTION: Single module reused across all environments
# No backend configuration needed - handled by Terragrunt!

# Using local provider to create network configuration files
resource "local_file" "network_config" {
  filename        = "${path.module}/network-config.json"
  content = jsonencode({
    environment  = var.environment
    network_cidr = var.network_cidr
    subnet_count = var.subnet_count
  })
  file_permission = "0644"
}

# Simulate network resources with null_resource
resource "null_resource" "network" {
  triggers = {
    network_cidr = var.network_cidr
    environment  = var.environment
  }
}
