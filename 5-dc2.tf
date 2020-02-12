####################################
####### DC 2 #######################
####################################

# Creating a NIC for internal network on DC2
resource "azurerm_network_interface" "dc2_internalnic" {
    name                = "dc2_intnic"
    location            = "${var.location}"
    resource_group_name = "${var.rg}"
    ip_configuration {
        name                          = "dc2_internal"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
    }
    dns_servers         = ["${var.int_dns_address}"]
}

#Creating DC2 VM
resource "azurerm_virtual_machine" "dc2sub" {
    name                         = "dc2sub"
    resource_group_name          = "${var.rg}"
    location                     = "${var.location}"
    network_interface_ids        = ["${azurerm_network_interface.dc2_internalnic.id}"]
    vm_size                      = "Standard_D1_v2"
    primary_network_interface_id = "${azurerm_network_interface.dc2_internalnic.id}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2012-R2-Datacenter"
        version = "latest"
    }

    storage_os_disk {
        name    = "dc2disk"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name  = "DC2"
        admin_username = "${var.username}"
        admin_password = "${var.password }"
    }

    os_profile_windows_config {
        provision_vm_agent = true
    }
}
