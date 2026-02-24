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

resource "aws_internet_gateway" "this" {
   vpc_id = aws_vpc.VPC.id 
   tags = { Name = "${var.vpc_name}-igw "}
}


# Only create an Elastic IP and NAT gateway if VPC name is "Singapore-Hub"

resource "aws_eip" "nat" {
  count = var.vpc_name == "Singapore-Hub" ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
   count = var.vpc_name == "Singapore-Hub" ? 1 : 0 
   allocation_id = aws_eip.nat[0].id 
   subnet_id = aws_subnet.Public.id 
   tags = { Name = "${var.vpc_name}-nat"}
}

resource "aws_route_table" "Public" {
   vpc_id = aws_vpc.VPC.id 
   tags = { Name = "${var.vpc_name}-Public-RT"}
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.VPC.id
  tags = { Name = "${var.vpc_name}-Private-RT" }
}

resource "aws_route" "private_to_internet" {
  count                  = var.vpc_name == "Singapore-Hub" ? 1 : 0 
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.Public.id
  route_table_id = aws_route_table.Public.id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}




  
output "vpc_id" { value = aws_vpc.VPC.id }
output "public_subnet_id" { value = aws_subnet.Public.id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "vpc_cidr" { value = aws_vpc.VPC.cidr_block } 
output "igw_id" { value = aws_internet_gateway.this.id }
output "public_route_table_id" { value = aws_route_table.Public.id }
output "private_route_table_id" { value = aws_route_table.private.id }
