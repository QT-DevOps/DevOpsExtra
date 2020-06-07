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
