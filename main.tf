module "hub_vpc" {
  source              = "./modules/vpc"
  vpc_name            = "Singapore-hub"
  vpc_cidr            = "10.10.0.0/16"
  public_subnet_cidr  = "10.10.0.0/24"
  private_subnet_cidr = []
  azs                 = ["ap-southeast-1a"]

}

# App VPC (Productive Workload)
module "app_vpc" {
  source              = "./modules/vpc"
  vpc_name            = "SG-App-VPC"
  
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = ["10.0.2.0/24", "10.0.3.0/24"]
  azs                 = ["ap-southeast-1a", "ap-southeast-1b"]

}

module "tgw" {
  source        = "./modules/transit_gateway"
  tgw_name      = "Central-TGW"
  hub_vpc_id    = module.hub_vpc.vpc_id
  hub_subnet_id = module.hub_vpc.public_subnet_id
  app_vpc_id    = module.app_vpc.vpc_id
  app_subnet_id = module.app_vpc.private_subnet_ids[0]
}


module "app_server" {
  source        = "./modules/EC2"
  instance_name = "SG-App-Server"
  vpc_id        = module.app_vpc.vpc_id
  subnet_id     = module.app_vpc.private_subnet_ids[0] # Put it in first private subnet
}

module "rds" {
  source        = "./modules/database"
  db_name       = "productiondb"
  vpc_id        = module.app_vpc.vpc_id
  db_subnet_ids = module.app_vpc.private_subnet_ids
  app_vpc_cidr  = module.app_vpc.vpc_cidr
  db_password   = var.db_password
}

resource "aws_route_table" "app_private" {
  vpc_id = module.app_vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = module.tgw.tgw_id
  }
  tags = { Name = "App-Private-RT"}
}

resource "aws_route_table_association" "app_private_assoc" {
   count = length(module.app_vpc.private_subnet_ids)
   subnet_id = module.app_vpc.private_subnet_ids[count.index]
   route_table_id = aws_route_table.app_private.id 
}

resource "aws_internet_gateway" "hub_igw" {
  vpc_id = module.hub_vpc.vpc_id
  tags = {
    Name = "SingaporeHub-igw"
  }
}
resource "aws_route_table" "hub_public_rt" {
  vpc_id = module.hub_vpc.vpc_id 
  # This route sends NAT Gateway traffic out to the internet
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hub_igw.id
  }

  # This route sends return traffic back to your App VPC via TGW
  route {
    cidr_block = "10.0.0.0/16"
    transit_gateway_id = module.tgw.tgw_id
  }
  tags = { Name = "Hub-Public-RT" }
}

resource "aws_route_table_association" "hub_public_assoc" {
  subnet_id      = module.hub_vpc.public_subnet_id
  route_table_id = aws_route_table.hub_public_rt.id
}

# Reserve a public static IP for the NAT gateway

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = { Name = "Hub-VPC-nat-eip"}
}

resource "aws_nat_gateway" "hub_nat" {
  allocation_id = aws_eip.nat_eip.id 
  subnet_id = module.hub_vpc.public_subnet_id
  depends_on = [aws_internet_gateway.hub_igw]
  tags = { Name = "singaporehub-vpc-nat-gateway"}
}

