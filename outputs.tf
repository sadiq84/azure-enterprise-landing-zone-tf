output "management_group_root_id" {
  description = "ID of the root Enterprise Management Group."
  value       = azurerm_management_group.root.id
}

output "hub_virtual_network_id" {
  description = "Resource ID of the Central Connectivity Hub VNet."
  value       = azurerm_virtual_network.hub.id
}

output "azure_firewall_private_ip" {
  description = "Private IP address of the centralized Azure Firewall for UDR routing."
  value       = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
}

output "spoke_corp_virtual_network_id" {
  description = "Resource ID of the Corp Workload Spoke VNet."
  value       = azurerm_virtual_network.spoke_corp.id
}
