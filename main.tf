# To prevent token refresh error run this before deployment: az account get-access-token

provider "azurerm" {
    features {}

  # version = "=1.34.0"
  # subscription_id = "${var.subscription_id}"
  # client_id       = "${var.client_id}"
  # client_secret   = "${var.client_sec}"
  # tenant_id       = "${var.tenant_id}"
}

# resource group is taken from variables.tf
# to prevent Terraform destroy from deleting it (we want to use the same one each time)