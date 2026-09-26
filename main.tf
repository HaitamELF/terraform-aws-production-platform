data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  name        = "production-platform"
  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

module "iam" {
  source = "./modules/iam"

  name        = "production-platform"
  environment = "dev"
}

module "security" {
  source = "./modules/security"

  name             = "production-platform"
  environment      = "dev"
  vpc_id           = module.vpc.vpc_id
  application_port = 8000
}

module "compute" {
  source = "./modules/compute"

  enabled = false

  name        = "production-platform"
  environment = "dev"

  subnet_id = module.vpc.private_subnet_ids[0]

  security_group_id = module.security.ec2_security_group_id

  instance_profile_name = module.iam.ec2_instance_profile_name

  instance_type = "t3.micro"
}

module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  enabled = false

  name        = "production-platform"
  environment = "dev"

  aws_region = var.aws_region

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  ec2_security_group_id = module.security.ec2_security_group_id
}