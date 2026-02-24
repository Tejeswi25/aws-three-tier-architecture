variable "aws_region" {
  default = "ap-southeast-1"
}

variable "db_password" {
  type      = string
  sensitive = true
}