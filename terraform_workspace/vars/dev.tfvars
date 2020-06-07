groupname               = "terraformdev"
location                = "centralus"
vnetcidr                = "192.168.0.0/16"
subnetnames             = ["web", "app", "db", "management"]
password                = "devops@qt123"
vmsize                  = "Standard_B1s"
osdisksize              = "Premium_LRS"
terraformazurebackend   = {
        storage_account_name = "qtstoragefortfstate"
        container_name       = "terraform"
        key                 = "default.terraform.tfstate"
        resource_group_name = "terraformstate"

}