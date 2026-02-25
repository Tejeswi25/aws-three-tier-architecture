variable "db_name" {}
variable "vpc_id" {}
variable "db_subnet_ids" { type = list(string) }
variable "app_vpc_cidr" {}
variable "db_password" { sensitive = true }

resource "aws_db_subnet_group" "this" {
    name = "${var.db_name}-sng1"
    subnet_ids = var.db_subnet_ids
}

resource "aws_security_group" "db_sg" {
    name = "${var.db_name}-sg"
    vpc_id = var.vpc_id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [var.app_vpc_cidr] 
    }
}
  
resource "aws_db_instance" "this" {
    allocated_storage = 20 
    engine = "mysql"
    instance_class = "db.t3.micro"
    db_subnet_group_name = aws_db_subnet_group.this.name 
    vpc_security_group_ids = [ aws_security_group.db_sg.id ]
    username = "admin"
    password = var.db_password
    skip_final_snapshot = true 
}

output "db_instance_endpoint" { value = aws_db_instance.this.id }