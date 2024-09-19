# VPC Steup
resource "aws_vpc" "vpc_node" {
 cidr_block = var.vpc_cidr
 tags = {
    Name = "Kubernetes-VPC"
  }
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

resource "aws_route_table_association" "rta_private" {
  subnet_id      = aws_subnet.sub_private.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_security_group" "aws_sg_master" {
  name        = "k8s-master-sg"
  description = "Security group for Kubernetes master node"
  vpc_id      = aws_vpc.vpc_node.id
  
}

resource "aws_vpc_security_group_ingress_rule" "master_ingress_https" {
  security_group_id = aws_security_group.aws_sg_master.id
  cidr_ipv4         = aws_vpc.vpc_node.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "master_ingress_k8s" {
  security_group_id = aws_security_group.aws_sg_master.id
  cidr_ipv4         = aws_vpc.vpc_node.cidr_block
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443
}

resource "aws_vpc_security_group_egress_rule" "master_egress" {
  security_group_id = aws_security_group.aws_sg_master.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

resource "aws_security_group" "aws_sg_worker" {
  name        = "k8s-worker-sg"
  description = "Security group for Kubernetes worker node"
  vpc_id      = aws_vpc.vpc_node.id
  
}

resource "aws_vpc_security_group_ingress_rule" "worker_ingress_https" {
  security_group_id = aws_security_group.aws_sg_worker.id
  cidr_ipv4         = aws_vpc.vpc_node.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "worker_ingress_k8s" {
  security_group_id = aws_security_group.aws_sg_worker.id
  cidr_ipv4         = aws_vpc.vpc_node.cidr_block
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443
}

resource "aws_vpc_security_group_egress_rule" "worker_egress" {
  security_group_id = aws_security_group.aws_sg_worker.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# EC2 Instances for Master and Worker Node

resource "aws_instance" "master" {
  ami           = var.ami_id
  instance_type = "t3.medium"
  key_name      = var.key_name
  security_groups = [aws_security_group.aws_sg_master.id]
  subnet_id     = aws_subnet.sub_public.id

  tags = {
    Name = "K8s Master"
  }
}

resource "aws_instance" "worker" {
  count         = var.worker_count
  ami           = var.ami_id
  instance_type = "t3.small"
  key_name      = var.key_name
  security_groups = [aws_security_group.aws_sg_worker.id]
  subnet_id     = aws_subnet.sub_private.id

  tags = {
    Name = "K8s Worker ${count.index + 1}"
  }
}