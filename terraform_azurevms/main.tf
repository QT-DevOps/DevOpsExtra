resource "azurerm_resource_group" "terraform" {
    location                = var.location
    name                    = var.groupname 
}

resource "azurerm_virtual_network" "vnet" {
    resource_group_name     =  var.groupname
    address_space           =  [var.vnetcidr]
    location                =  var.location
    name                    =  local.network_name
    depends_on              = [azurerm_resource_group.terraform]
    tags                    = local.common_tags

}

resource "azurerm_subnet" "subnets" {
    count                   = length(var.subnetnames)

    resource_group_name     = var.groupname
    virtual_network_name    = local.network_name
    address_prefixes        = [cidrsubnet(var.vnetcidr,8,count.index)]
    name                    = var.subnetnames[count.index]     
    depends_on              = [azurerm_resource_group.terraform, azurerm_virtual_network.vnet]

}

resource "azurerm_public_ip" "mypublicip" {
    name                    = local.publicip_name
    resource_group_name     = var.groupname
    location                = var.location
    allocation_method       = "Dynamic"  
    tags                    = local.common_tags
    depends_on              = [azurerm_resource_group.terraform, azurerm_virtual_network.vnet]
  
}

resource "azurerm_network_security_group" "openall" {
    name                    = local.nsgname
    location                = var.location
    resource_group_name     = var.groupname
    tags                    = local.common_tags
    security_rule {
        name                        = "openalloutgoing"
        access                      = "Allow"
        destination_address_prefix  = "*"
        source_address_prefix       = "*"
        priority                    = 300
        direction                   = "Outbound"
        protocol                    = "*"
        source_port_range           = "*"
        destination_port_range      = "*"
    } 

    security_rule {
        name                        = "openallincoming"
        access                      = "Allow"
        destination_address_prefix  = "*"
        source_address_prefix       = "*"
        priority                    = 300
        direction                   = "Inbound"
        protocol                    = "*"
        source_port_range           = "*"
        destination_port_range      = "*"
    } 

    depends_on              = [ azurerm_public_ip.mypublicip]
  
}

resource "azurerm_network_interface" "vmnic" {
        name                                = local.nicname
        location                            = var.location
        resource_group_name                 = var.groupname
        ip_configuration {
            name                            = "${local.nicname}ipconfig"
            subnet_id                       = azurerm_subnet.subnets[0].id
            private_ip_address_allocation   = "Dynamic"
            public_ip_address_id            = azurerm_public_ip.mypublicip.id
        }
        tags                                = local.common_tags

        depends_on              = [ azurerm_public_ip.mypublicip, azurerm_subnet.subnets]
  
}

resource "random_id" "storagerandom" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.terraform.name
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "diagstorage" {
    name                            = "qt${random_id.storagerandom.hex}" 
    resource_group_name             = var.groupname
    location                        = var.location
    account_replication_type        = "LRS"
    account_tier                    = "Standard"
    tags                            = local.common_tags

    depends_on              = [ azurerm_public_ip.mypublicip, azurerm_subnet.subnets, random_id.storagerandom]

}

resource "azurerm_linux_virtual_machine" "qtvm" {
    name                            = local.vmname
    location                        = var.location
    resource_group_name             = var.groupname
    size                            = "Standard_B1s"
    admin_username                  = local.username
    admin_password                  = var.password
    disable_password_authentication = false
    network_interface_ids           = [azurerm_network_interface.vmnic.id]
    source_image_reference {
        publisher                   = "Canonical"
        offer                       = "UbuntuServer"
        sku                         = "18.04-LTS"
        version                     = "latest"
    }

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    tags                            = local.common_tags

    provisioner "remote-exec" {
        inline              = [
            "sudo apt-get update",
            "sudo apt-get install apache2 -y"
        ]


        connection {
            host     = self.public_ip_address
            user     = self.admin_username
            password = self.admin_password
        }
    }
  
}