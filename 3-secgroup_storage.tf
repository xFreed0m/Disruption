# Security group to enable RDP+SSH+WEB access to the public IPs
data "external" "whatismyip" {
  program = ["${path.module}/whatismyip.sh"]
}

resource "azurerm_network_security_group" "secgroup" {
  name                = "myNetworkSecurityGroup"
  location            = var.location
  resource_group_name = var.rg

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${data.external.whatismyip.result["internet_ip"]}/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${data.external.whatismyip.result["internet_ip"]}/32"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WEB"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${data.external.whatismyip.result["internet_ip"]}/32"
    destination_address_prefix = "*"
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.rg
  }

  byte_length = 8
}

resource "azurerm_storage_account" "storageacct" {
  name                     = "storage${random_id.randomId.hex}"
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storagecontainer" {
  name                  = "storagecontainer"
  storage_account_name  = azurerm_storage_account.storageacct.name
  container_access_type = "private"
}

