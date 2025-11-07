output "network_cidr" {
  description = "The CIDR block of the network"
  value       = var.network_cidr
}

output "network_id" {
  description = "Simulated network ID"
  value       = null_resource.network.id
}

output "config_file" {
  description = "Path to network configuration file"
  value       = local_file.network_config.filename
}
