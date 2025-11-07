# Shared Application Module
# SOLUTION: Single module reused across all environments
# No backend configuration needed - handled by Terragrunt!

# Using local provider to create app configuration
resource "local_file" "app_config" {
  filename        = "${path.module}/app-config.json"
  content = jsonencode({
    environment  = var.environment
    app_name     = var.app_name
    replicas     = var.replicas
    network_cidr = var.network_cidr
  })
  file_permission = "0644"
}

# Simulate application deployment
resource "null_resource" "app" {
  triggers = {
    app_name    = var.app_name
    environment = var.environment
    replicas    = var.replicas
  }
}
