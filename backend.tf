terraform {
  backend "s3" {
    bucket = "three-tier-architecture-feb23"
    key    = "projects/three-tier/terraform.tfstate"
    region = "us-east-1"
  }
}