variable "db_name" {
    type = string 
}

variable "vpc_id" {
   type = string
}

variable "db_subnet_ids"{
   type = list(string)
}

variable "app_vpc_cidr" {
   description = "The CIDR range allowed to connect to the DB"
   type = string
}

variable "db_password" {
   type = password
   sensitive = true
}