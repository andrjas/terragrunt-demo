output "app_name" {
  description = "Name of the deployed application"
  value       = var.app_name
}

output "app_id" {
  description = "Simulated application ID"
  value       = null_resource.app.id
}

output "config_file" {
  description = "Path to application configuration file"
  value       = local_file.app_config.filename
}
