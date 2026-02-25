variable "vpc_cidr" {
}

variable "vpc_name" {
}

variable "public_subnet_cidr" {
}

variable "private_subnet_cidr" {
    type = list(string)
}

variable "azs" {
  type = list(string)
}



resource "aws_vpc" "VPC" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = { Name = var.vpc_name}
}

resource "aws_subnet" "Public" {
    vpc_id = aws_vpc.VPC.id 
    cidr_block = var.public_subnet_cidr
    availability_zone = var.azs[0]
    map_public_ip_on_launch = true 
    tags = { Name = "${var.vpc_name}-public" }
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr)
    vpc_id = aws_vpc.VPC.id 
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = var.azs[count.index] 
    tags = { Name = "${var.vpc_name}-private-${count.index}" }
}


output "vpc_id" { value = aws_vpc.VPC.id }
output "public_subnet_id" { value = aws_subnet.Public.id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "vpc_cidr" { value = aws_vpc.VPC.cidr_block } 

