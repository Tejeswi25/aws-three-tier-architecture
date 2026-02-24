variable "tgw_name"{
    description = "The name tag for the Transit Gateway"
    type = string
}

variable "hub_vpc_id" {
    description = "The ID of the Hub VPC"
    type = "string"
}

variable "hub_subnet_id" {
    description = "The Subnet ID in the Hub VPC where the TGW will attach"
}

variable "app_vpc_id"{
    description = "The ID of the Application VPC"
    type = string
}

variable "app_subnet_id" {
    description = "The subnet ID in the App VPC where the TGW will attach"
    type = string
}
  


  

