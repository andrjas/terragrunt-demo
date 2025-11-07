variable "network_cidr" {
  description = "CIDR block for the network"
  type        = string
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 2
}
