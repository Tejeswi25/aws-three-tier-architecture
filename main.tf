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
  db_name       = "ProductionDB"
  vpc_id        = module.app_vpc.vpc_id
  db_subnet_ids = module.app_vpc.private_subnet_ids
  app_vpc_cidr  = module.app_vpc.vpc_cidr
  db_password   = var.db_password
}