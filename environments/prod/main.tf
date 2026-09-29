data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "../../modules/vpc"

  name        = var.project_name
  environment = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count
  )

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source = "../../modules/iam"

  name        = var.project_name
  environment = var.environment
}

module "security" {
  source = "../../modules/security"

  name             = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  application_port = var.application_port
}

module "compute" {
  source = "../../modules/compute"

  enabled = var.compute_enabled

  name        = var.project_name
  environment = var.environment

  subnet_id = module.vpc.private_subnet_ids[0]

  security_group_id = module.security.ec2_security_group_id

  instance_profile_name = module.iam.ec2_instance_profile_name

  instance_type = var.instance_type

  cloudwatch_namespace = "${var.project_name}/${var.environment}"
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  enabled = var.vpc_endpoints_enabled

  name        = var.project_name
  environment = var.environment

  aws_region = var.aws_region

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  ec2_security_group_id = module.security.ec2_security_group_id

  private_route_table_ids = module.vpc.private_route_table_ids

}

module "secrets" {
  source = "../../modules/secrets"

  name        = var.project_name
  environment = var.environment

  ec2_role_name = module.iam.ec2_role_name

  aws_region     = var.aws_region
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "observability" {
  source = "../../modules/observability"

  name        = var.project_name
  environment = var.environment

  ec2_role_name = module.iam.ec2_role_name

  log_retention_days = var.log_retention_days

  compute_enabled = var.compute_enabled
  instance_id     = module.compute.instance_id

  cpu_alarm_threshold = var.cpu_alarm_threshold
}