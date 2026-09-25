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