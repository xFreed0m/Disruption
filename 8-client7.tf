####################################
####### Client 7 #######################
####################################

# Creating a NIC for internal network on Client7
resource "azurerm_network_interface" "client7_internalnic" {
    name                = "client7_intnic"
    location            = "${var.location}"
    resource_group_name = "${var.rg}"
    ip_configuration {
        name                          = "client7_internal"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
    }
}

#Creating client7 VM
resource "azurerm_virtual_machine" "client7" {
    name                         = "client7"
    resource_group_name          = "${var.rg}"
    location                     = "${var.location}"
    network_interface_ids        = ["${azurerm_network_interface.client7_internalnic.id}"]
    vm_size                      = "Standard_D1_v2"
    primary_network_interface_id = "${azurerm_network_interface.client7_internalnic.id}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsDesktop"
        offer = "Windows-7"
        sku = "win7-enterprise"
        version = "latest"
    }

    storage_os_disk {
        name    = "client7disk"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name  = "client7"
        admin_username = "${var.username}"
        admin_password = "${var.password}"
    }

    os_profile_windows_config {
        provision_vm_agent = true    
    }
}
