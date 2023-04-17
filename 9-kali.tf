###################################
###### Kali #######################
###################################

# Accepting Kali license (due of being an Azure Marketplace image)
# resource "azurerm_marketplace_agreement" "kali-linux" {
#   publisher = "kali-linux"
#   offer     = "kali-linux"
#   plan      = "kali"
# }

# External NIC to access Kali from the outside
/* resource "azurerm_network_interface" "kali_externalnic" {
  name                      = "kali_extnic"
  location                  = var.location
  resource_group_name       = var.rg
  network_security_group_id = azurerm_network_security_group.secgroup.id

  ip_configuration {
    primary                       = true
    name                          = "kali_externalnic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kalipublicip.id
  }
}
 */
# Creating a NIC for internal network on Kali
/* resource "azurerm_network_interface" "kali_internalnic" {
  name                = "kali_intnic"
  location            = var.location
  resource_group_name = var.rg
  ip_configuration {
    name                          = "kali_internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
} */

#Creating kali-linux VM
/* resource "azurerm_virtual_machine" "kali" {
  name                             = "kali"
  resource_group_name              = var.rg
  location                         = var.location
  network_interface_ids            = [azurerm_network_interface.kali_externalnic.id, azurerm_network_interface.kali_internalnic.id]
  vm_size                          = "Standard_D1_v2"
  primary_network_interface_id     = azurerm_network_interface.kali_externalnic.id
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "kali-linux"
    offer     = "kali-linux"
    sku       = "kali"
    version   = "latest"
  }

  storage_os_disk {
    name          = "kalidisk"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "kali"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/landlord/.ssh/authorized_keys"
      key_data = var.pub_key
    }
  } */

  # Mandatory section for Marketplace VMs
/*   plan {
    name      = "kali"
    publisher = "kali-linux"
    product   = "kali-linux"
  }
} */

# Kali update && upgrade
# resource "azurerm_virtual_machine_extension" "kali_commands" {
#  name                 = "kali_commands"
#  location             = var.location
#  resource_group_name  = var.rg
#  virtual_machine_name = azurerm_virtual_machine.kali.name
#  publisher            = "Microsoft.Azure.Extensions"
#  type                 = "CustomScript"
#  type_handler_version = "2.0"
#  settings             =
#  <<SETTINGS
#   {
#      "commandToExecute": "DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
#   }
#SETTINGS
#
#
#  depends_on = [azurerm_virtual_machine.kali]
#}
