####################################
####### Fileserver #######################
####################################

# Creating a NIC for internal network on Fileserver
resource "azurerm_network_interface" "fileserver_internalnic" {
    name                = "fileserver_intnic"
    location            = var.location
    resource_group_name = var.rg
    ip_configuration {
        name                          = "fileserver_internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
    dns_servers         = ["${var.int_dns_address}"]

}

resource "azurerm_network_interface" "fileserver_externalnic" {
    name                = "fileserver_extnic"
    location            = var.location
    resource_group_name = var.rg
    network_security_group_id = azurerm_network_security_group.secgroup.id

    ip_configuration {
        primary                       = true
        name                          = "fileserver_externalnic"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.fileserverpublicip.id
    }
}

# Creating Fileserver VM
resource "azurerm_virtual_machine" "fileserver" {
    name                         = "fileserver"
    resource_group_name          = var.rg
    location                     = var.location
    network_interface_ids        = ["${azurerm_network_interface.fileserver_internalnic.id}","${azurerm_network_interface.fileserver_externalnic.id}"]
    vm_size                      = "Standard_D2_v2"
    primary_network_interface_id = azurerm_network_interface.fileserver_externalnic.id
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name    = "fileserverdisk"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name  = "fileserver"
        admin_username = var.username
        admin_password = var.password
    }

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
