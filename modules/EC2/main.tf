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

# Create the IAM Role

resource "aws_iam_role" "ec2_ssm_role" {
    name = "app_server-ssm-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })
}

# Attach the Managed Policy

resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
    role =  aws_iam_role.ec2_ssm_role.name 
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the Instance Profile

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
    name = "app-server-ssm-profile"
    role = aws_iam_role.ec2_ssm_role.name 
}
resource "aws_instance" "app_server" {
    ami = "ami-0ac0e4288aa341886"
    instance_type = "t3.micro"
    iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name 
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    tags = { Name = var.instance_name }
}

output "instance_id" { value = aws_instance.app_server.id }
