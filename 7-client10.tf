####################################
####### Client 10 #######################
####################################

# Creating a NIC for internal network on Client10
resource "azurerm_network_interface" "client10_internalnic" {
  name                = "client10_intnic"
  location            = var.location
  resource_group_name = var.rg
  ip_configuration {
    name                          = "client10_internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Creating client10 VM
resource "azurerm_virtual_machine" "client10" {
  name                             = "client10"
  resource_group_name              = var.rg
  location                         = var.location
  network_interface_ids            = [azurerm_network_interface.client10_internalnic.id]
  vm_size                          = "Standard_D1_v2"
  primary_network_interface_id     = azurerm_network_interface.client10_internalnic.id
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "rs5-pro"
    version   = "latest"
  }

  storage_os_disk {
    name          = "client10disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "client10"
    admin_username = var.username
    admin_password = var.password
  }

  # Autologon to bypass the OOBE screen and be able to join client10 to the domain
  os_profile_windows_config {
    provision_vm_agent = true
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.username}</Username></AutoLogon>"
    }
  }
}

