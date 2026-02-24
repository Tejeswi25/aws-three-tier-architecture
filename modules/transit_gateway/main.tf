variable "tgw_name" {}
variable "hub_vpc_id" {}
variable "hub_subnet_id" {}
variable "app_vpc_id"{}
variable "app_subnet_id" {}

resource "aws_ec2_transit_gateway" "this"{
    description = "Singapore Hub TGW"
    tags = { Name = var.tgw_name }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = { Name = "main-tgw-rt" }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "hub_attach" {
    vpc_id = var.hub_vpc_id
    subnet_ids = [var.hub_subnet_id]
    transit_gateway_id = aws_ec2_transit_gateway.this.id 
    

    tags = { Name = "hub-attachment" } 
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app_attach" {
    subnet_ids = [var.app_subnet_id ]
    transit_gateway_id = aws_ec2_transit_gateway.this.id 
    vpc_id = var.app_vpc_id
    tags = { Name = "app-attachment" }
}


resource "aws_ec2_transit_gateway_route" "default_egress" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}
  
output "tgw_id" { value = aws_ec2_transit_gateway.this.id } 