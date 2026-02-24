variable "vpc_cidr" {
    type = string
}

# Name tag for the VPC resources
variable "vpc_name" {
  type = string          
}

#List of availability zones in the region
variable "azs" {
  type = list(string)    
}

#Public Subnet CIDR
variable "public_subnet_cidr" {
  type = string
}

#Private Subnet CIDR
variable "private_subnet_cidr" {
  type = list(string)
}
