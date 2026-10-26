
# Public IP addresses for all four VMs
output "public_ips" {
  description = "Public IP addresses of the four Azure VMs"

  value = {
    for index, name in var.vm_names :
    name => azurerm_public_ip.vm[index].ip_address
  }
}

# Private IP addresses for all four VMs
output "private_ips" {
  description = "Private IP addresses of the four Azure VMs"

  value = {
    for index, name in var.vm_names :
    name => azurerm_network_interface.vm[index].private_ip_address
  }
}

# Virtual machine names
output "vm_names" {
  description = "Names of the four Azure VMs"
  value       = azurerm_linux_virtual_machine.vm[*].name
}

# Resource group name for cleanup
output "resource_group_name" {
  description = "Azure resource group containing the assignment VMs"
  value       = azurerm_resource_group.main.name
}
