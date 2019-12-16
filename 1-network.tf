resource "azurerm_virtual_network" "vnet" {
    name                = "vms_vnet"
    address_space       = ["192.0.0.0/8"]
    location            = var.location
    resource_group_name = var.rg
}

resource "azurerm_subnet" "subnet" {
    name                 = "vms_subnet"
    resource_group_name  = var.rg
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix       = "192.167.1.0/24"
}
