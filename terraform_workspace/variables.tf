variable "groupname" {
    type    = string
    default = "terraform"
}

variable "location" {
    type    = string
    default = "centralus"
}

variable "vnetcidr" {
    type    = string
    default = "192.168.0.0/16"
}

variable subnetnames {
    default = ["web", "app", "db", "management"]
}

variable password {
    default = "devops@qt123"
}

locals {
    network_name    = "ntier"
    publicip_name   = "ntierpublic"
    nsgname         = "openall"
    nicname         = "vmnic"
    vmname          = "qtazure"
    username        = "qtdevops"
}

locals {
    common_tags = {
        purpose             = "learning"
        created_by          = "teraform"
    }
}

variable vmsize {
    default         = "Standard_B1s"
}

variable osdisksize {
    default         = "Premium_LRS"
    
}


variable terraformazurebackend {
    type            = map
    default         = {
        storage_account_name = "qtstoragefortfstate"
        container_name       = "terraform"
        key                 = "default.terraform.tfstate"
        resource_group_name = "terraformstate"

    }

}

locals {
    terraformstatefile  = "${terraform.workspace}.terraform.tfstate"
}
