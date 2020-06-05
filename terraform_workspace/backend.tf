terraform{
    backend "azurerm" {
        storage_account_name = "qtterraformstate"
        container_name       = "terraform"
        key                 = "default.terraform.tfstate"
        resource_group_name = "terraformstate"
    }
}