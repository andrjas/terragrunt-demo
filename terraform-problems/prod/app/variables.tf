variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 1
}

variable "network_cidr" {
  description = "Network CIDR block"
  type        = string
}
