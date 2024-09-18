resource "aws_vpc" "vpc_node" {
 cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc_node.id
    tags = {
        Name = "IGW"
    }
}

resource "aws_subnet" "sub_public" {
    vpc_id = aws_vpc.vpc_node.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
    tags = {
    Name = "Public Subnet 1"       
    }
}

resource "aws_subnet" "sub_private" {
    vpc_id = aws_vpc.vpc_node.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = false
    tags = {
        Name = "Private Subnet 1"
    }
}

resource "aws_eip" "lb" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.sub_public.id

  tags = {
    Name = "gw NAT"
  }
}


resource "aws_route_table" "rt_public" {
    vpc_id = aws_vpc.vpc_node.id
    route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.igw.id       
    }
    tags = {
        Name = "RT_PUBLIC"
    }
}

resource "aws_route_table" "rt_private" {
    vpc_id = aws_vpc.vpc_node.id
    route {
    cidr_block = var.rt_cidr
    nat_gateway_id = aws_nat_gateway.ng.id       
    }
    tags = {
        Name = "RT_PRIVATE"
    }
}

resource "aws_route_table_association" "rta_public" {
  subnet_id      = aws_subnet.sub_public.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_public_private" {
  subnet_id      = aws_subnet.sub_private.id
  route_table_id = aws_route_table.rt_private.id
}
