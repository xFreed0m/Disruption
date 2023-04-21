###################################
###### Kali #######################
###################################

# Accepting Kali license (due of being an Azure Marketplace image)
 resource "azurerm_marketplace_agreement" "kali-linux" {
   publisher = "kali-linux"
   offer     = "kali"
   plan      = "kali-20231"
 } 

# External NIC to access Kali from the outside
resource "azurerm_network_interface" "kali_externalnic" {
  name                      = "kali_extnic"
  location                  = var.location
  resource_group_name       = var.rg
  #network_security_group_id = azurerm_network_security_group.secgroup.id


#  ip_configuration {
#    primary                       = true
#    name                          = "kali_externalnic"
#    subnet_id                     = azurerm_subnet.subnet.id
#    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id          = azurerm_public_ip.kalipublicip.id
#  }
#}

# Creating a NIC for internal network on Kali
resource "azurerm_network_interface" "kali_internalnic" {
  name                = "kali_intnic"
  location            = var.location
  resource_group_name = var.rg
  ip_configuration {
    name                          = "kali_internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.int_kali_address
  }
}

#Creating kali-linux VM
resource "azurerm_linux_virtual_machine" "kali" {
  name                             = "kalivm"
  resource_group_name              = var.rg
  location                         = var.location
  network_interface_ids            = [azurerm_network_interface.kali_externalnic.id, azurerm_network_interface.kali_internalnic.id]
  size                             = "Standard_DS1_v2"
  #primary_network_interface_id     = azurerm_network_interface.kali_externalnic.id
  #delete_os_disk_on_termination    = true
  #delete_data_disks_on_termination = true
  admin_username                   = var.username

  
  source_image_reference  {
    publisher = "kali-linux"
    offer     = "kali"
    sku       = "kali-20231"
    version   = "latest"
  }

  # Mandatory section for Marketplace VMs
  plan                    {
    name      = "kali-20231"
    product   = "kali"
    publisher = "kali-linux"
  }

  os_disk {
    name          = "kalidisk"
    caching       = "ReadWrite"
    #create_option = "FromImage"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
  username   = var.username
  public_key = var.pub_key
  }

}


# Kali update && upgrade
resource "azurerm_virtual_machine_extension" "kali_commands" {
  name                 = "kali_commands"
  #location             = var.location
  #resource_group_name  = var.rg
  #virtual_machine_name = azurerm_virtual_machine.kali.name
  virtual_machine_id   = azurerm_linux_virtual_machine.kali.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings             = <<SETTINGS
   {
      "commandToExecute": "DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
   }
SETTINGS


  depends_on = [azurerm_linux_virtual_machine.kali]
}
