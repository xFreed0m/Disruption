#############################
######### Outputs
#############################
# Printing the ip addresses of the machines when deployment is done
# DC1 Public IP
output "DC1_public_ip_address" {
  description = "The RDP Public IP of DC1"
  value       = azurerm_public_ip.dc1publicip.ip_address
}

output "fileserver_internal_ip_address" {
  description = "Fileserver internal IP"
  value       = azurerm_network_interface.fileserver_internalnic.private_ip_address
}

output "fileserver_external_ip_address" {
  description = "Fileserver External IP (Web)"
  value       = azurerm_public_ip.fileserverpublicip.ip_address
}

output "DC1_internal_ip_address" {
  description = "DC1 internal IP"
  value       = azurerm_network_interface.dc1_internalnic.private_ip_address
}

output "DC2_internal_ip_address" {
  description = "DC2_Sub internal IP"
  value       = azurerm_network_interface.dc2_internalnic.private_ip_address
}

output "client10_internal_ip_address" {
  description = "Windows Client 10 internal IP"
  value       = azurerm_network_interface.client10_internalnic.private_ip_address
}

output "client7_internal_ip_address" {
  description = "Windows client 7 internal IP"
  value       = azurerm_network_interface.client7_internalnic.private_ip_address
}

output "Kali_internal_ip_address" {
  description = "kali internal IP"
  value       = azurerm_network_interface.kali_internalnic.private_ip_address

  depends_on = [azurerm_network_interface.kali_internalnic]
}

# Kali Public IP
output "kali_public_ip_address" {
  description = "kali external IP"
  value       = azurerm_public_ip.kalipublicip.ip_address

  depends_on = [azurerm_linux_virtual_machine.kali]
}

