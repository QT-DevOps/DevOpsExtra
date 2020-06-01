resource "aws_vpc" "mainvpc" {
    cidr_block              = var.mainregioncidr

    tags                    = {
        Name                = "Main vpc"
    }
    enable_dns_hostnames    = true
}


resource "aws_vpc" "secondvpc" {
    cidr_block              = var.secondaryregioncidr
    provider                = aws.mumbai

    tags                    = {
        Name                = "Second VPC"
    } 
    enable_dns_hostnames    = true

    depends_on              = [ aws_vpc.mainvpc]
  
}

resource "aws_subnet" "mainsubnets" {
    count                   = var.subnetcount

    cidr_block              = cidrsubnet(var.mainregioncidr,8,count.index)
    vpc_id                  = aws_vpc.mainvpc.id
    depends_on              = [ aws_vpc.mainvpc]
  
}

resource "aws_subnet" "secondarysubnets" {
    count                   = var.subnetcount
    provider                = aws.mumbai
    cidr_block              = cidrsubnet(var.secondaryregioncidr,8,count.index)
    vpc_id                  = aws_vpc.secondvpc.id
    depends_on              = [ aws_vpc.secondvpc]
}

resource "aws_internet_gateway" "mainigw" {
    vpc_id                  = aws_vpc.mainvpc.id
    depends_on              = [aws_subnet.mainsubnets]
  
}

resource "aws_internet_gateway" "secondaryigw" {
    provider                = aws.mumbai
    vpc_id                  = aws_vpc.secondvpc.id
    depends_on              = [aws_subnet.secondarysubnets]
  
}


resource "aws_route_table" "mainpublicrt" {
    vpc_id                  = aws_vpc.mainvpc.id

    route  {
        cidr_block          = "0.0.0.0/0"
        gateway_id          = aws_internet_gateway.mainigw.id

    } 

    tags                    = {
        Name                = "Public"
    }
    depends_on              = [aws_internet_gateway.mainigw]
  
}

resource "aws_route_table" "secondarypublicrt" {
    vpc_id                  = aws_vpc.secondvpc.id
    provider                = aws.mumbai

    route  {
        cidr_block          = "0.0.0.0/0"
        gateway_id          = aws_internet_gateway.secondaryigw.id

    } 

    tags                    = {
        Name                = "Public"
    }

    depends_on              = [aws_internet_gateway.secondaryigw]
  
}

resource "aws_route_table_association" "mainsubnetsassc" {
    count                   = var.subnetcount
    subnet_id               = aws_subnet.mainsubnets[count.index].id
    route_table_id          = aws_route_table.mainpublicrt.id

    depends_on              = [aws_route_table.mainpublicrt]
  
}

resource "aws_route_table_association" "secondsubnetsassc" {
    count                   = var.subnetcount
    subnet_id               = aws_subnet.secondarysubnets[count.index].id
    route_table_id          = aws_route_table.secondarypublicrt.id
    provider                = aws.mumbai
    depends_on              = [aws_route_table.secondarypublicrt]
  
}

resource "aws_security_group" "openalloregon" { 
    description             = "This security group is to open all"
    name                    = "Openall"
    ingress {
        description         = "Open all incoming"
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
    }
    egress {
        description         = "Open all outgoing"
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
    }
    vpc_id                  = aws_vpc.mainvpc.id

    depends_on              = [aws_vpc.mainvpc]
  
}

resource "aws_security_group" "openallmumbai" { 
    description             = "This security group is to open all"
    name                    = "Openall"
    ingress {
        description         = "Open all incoming"
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
    }
    egress {
        description         = "Open all outgoing"
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
    }
    provider                = aws.mumbai
    vpc_id                  = aws_vpc.secondvpc.id

    depends_on              = [aws_vpc.secondvpc]
  
}



