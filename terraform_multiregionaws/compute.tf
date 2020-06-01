
data "aws_ami" "ubuntu18" { 
    owners      = ["099720109477"]
    most_recent = true

    filter {
        name    = "name"
        values  = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408"]
    }
  
}
locals {
    keyname     = "ownkey"
}

resource "aws_key_pair" "ownkey" { 
    key_name    = local.keyname
    public_key  = file("./ownkey.pub")
    
    depends_on  = [aws_route_table.mainpublicrt]
  
}

resource "aws_key_pair" "ownkeym" { 
    provider    = aws.mumbai
    key_name    = local.keyname
    public_key  = file("./ownkey.pub")

    depends_on  = [aws_route_table.secondarypublicrt]
  
}

/*
resource "null_resource" "provisionnow" { 

    connection {
            type                = "ssh"
            user                = "ubuntu"
            private_key         = file("./ownkey")
            host                = aws_instance.maininstance.public_ip
    }

    provisioner "file" {
        source                  = "./installapache.sh"
        destination             = "/tmp/install.sh"
    }

    provisioner "remote-exec" {
        on_failure              = continue
        inline                  = [
            "chmod +x /tmp/install.sh",
            "sh /tmp/install.sh"
        ]

            
    }

    depends_on                  = [aws_instance.maininstance]
  
}
*/

resource "aws_instance" "maininstance" {
    ami                         = data.aws_ami.ubuntu18.id
    key_name                    = local.keyname
    associate_public_ip_address = true
    instance_type               = "t2.micro"
    vpc_security_group_ids      = [aws_security_group.openalloregon.id]
    subnet_id                   = aws_subnet.mainsubnets[0].id


    depends_on  = [aws_key_pair.ownkey, aws_security_group.openalloregon]

    connection {
            type                = "ssh"
            user                = "ubuntu"
            private_key         = file("./ownkey")
            host                = aws_instance.maininstance.public_ip
    }

    provisioner "file" {
        source                  = "./installapache.sh"
        destination             = "/tmp/install.sh"
    }

    provisioner "remote-exec" {
        on_failure              = continue
        inline                  = [
            "chmod +x /tmp/install.sh",
            "sh /tmp/install.sh"
        ]

            
    }
  
}
