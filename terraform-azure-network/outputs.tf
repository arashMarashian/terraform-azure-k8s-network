output "virtual_network_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "network_security_group_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.k8s_nsg.id
}
