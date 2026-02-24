variable "instance_name" {
}

variable "subnet_id" {
}

variable "vpc_id" {
}

# Security Group for the App Server

resource "aws_security_group" "app_sg" {
       name = "${var.instance_name}-sg"
       vpc_id = var.vpc_id
       egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
       }
}

resource "aws_instance" "app_server" {
    ami = "ami-0df7a207adb894a1f"
    instance_type = "t3.micro"
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    tags = { Name = var.instance_name }
}

output "instance_id" { value = aws_instance.app_server.id }
