
####################################
####### DC 1 #######################
####################################

# Creating a NIC for internal network on DC1
resource "azurerm_network_interface" "dc1_internalnic" {
    name                = "dc1_intnic"
    location            = var.location
    resource_group_name = var.rg
    ip_configuration {
        name                          = "dc1_internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.int_dns_address
    }
}

# Creating a NIC for external network on DC1
resource "azurerm_network_interface" "dc1_externalnic" {
    name                = "dc1_extnic"
    location            = var.location
    resource_group_name = var.rg
    network_security_group_id = azurerm_network_security_group.secgroup.id

    ip_configuration {
        primary                       = true
        name                          = "dc1_externalnic"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.dc1publicip.id
    }
}

#Creating DC1 VM
resource "azurerm_virtual_machine" "dc1primary" {
    name                         = "dc1primary"
    resource_group_name          = var.rg
    location                     = var.location
    network_interface_ids        = ["${azurerm_network_interface.dc1_externalnic.id}","${azurerm_network_interface.dc1_internalnic.id}"]
    vm_size                      = "Standard_D1_v2"
    primary_network_interface_id = azurerm_network_interface.dc1_externalnic.id
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2012-R2-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name    = "dc1disk"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name  = "DC1"
        admin_username = var.username
        admin_password = var.password
    }

    os_profile_windows_config {
        provision_vm_agent = true
    }
}
