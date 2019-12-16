resource "azurerm_public_ip" "dc1publicip" {
    name                         = "DC1publicIP"
    location                     = var.location
    resource_group_name          = var.rg
    allocation_method            = "Static"
}
resource "azurerm_public_ip" "kalipublicip" {
    name                         = "KALIpublicIP"
    location                     = var.location
    resource_group_name          = var.rg
    allocation_method            = "Static"
}
resource "azurerm_public_ip" "fileserverpublicip" {
    name                         = "fileserverpublicIP"
    location                     = var.location
    resource_group_name          = var.rg
    allocation_method            = "Static"
}