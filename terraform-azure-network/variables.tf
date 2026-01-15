variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "westeurope"
}

variable "office_ip_range" {
  type        = string
  description = "IP range for office access (CIDR notation)"
}
