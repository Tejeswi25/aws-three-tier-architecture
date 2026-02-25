variable "tgw_name" {}
variable "hub_vpc_id" {}
variable "hub_subnet_id" {}
variable "app_vpc_id"{}
variable "app_subnet_id" {}

resource "aws_ec2_transit_gateway" "this"{
    description = "Singapore Hub TGW"
    tags = { Name = var.tgw_name }
}



resource "aws_ec2_transit_gateway_vpc_attachment" "app_attach" {
    subnet_ids = [var.app_subnet_id ]
    transit_gateway_id = aws_ec2_transit_gateway.this.id 
    vpc_id = var.app_vpc_id
    tags = { Name = "app-attachment" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "hub_attach" {
   subnet_ids = [var.hub_subnet_id]
   transit_gateway_id = aws_ec2_transit_gateway.this.id 
   vpc_id = var.hub_vpc_id
   tags = { Name = "hub-attachment" }
}


output "tgw_id" { value = aws_ec2_transit_gateway.this.id } 