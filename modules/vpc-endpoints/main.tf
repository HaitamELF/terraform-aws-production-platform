data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_security_group" "endpoints" {
  count = var.enabled ? 1 : 0

  name        = "${var.name}-${var.environment}-endpoints-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.name}-${var.environment}-endpoints-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_from_ec2" {
  count = var.enabled ? 1 : 0

  security_group_id = aws_security_group.endpoints[0].id

  referenced_security_group_id = var.ec2_security_group_id

  description = "Allow HTTPS from application EC2 instances"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_endpoint" "ssm" {
  count = var.enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints[0].id
  ]

  private_dns_enabled = true

  tags = {
    Name        = "${var.name}-${var.environment}-ssm-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = var.enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints[0].id
  ]

  private_dns_enabled = true

  tags = {
    Name        = "${var.name}-${var.environment}-ssmmessages-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_endpoint" "monitoring" {
  count = var.enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints[0].id
  ]

  private_dns_enabled = true

  tags = {
    Name        = "${var.name}-${var.environment}-monitoring-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_endpoint" "logs" {
  count = var.enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids = var.private_subnet_ids

  security_group_ids = [
    aws_security_group.endpoints[0].id
  ]

  private_dns_enabled = true

  tags = {
    Name        = "${var.name}-${var.environment}-logs-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enabled ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  tags = {
    Name        = "${var.name}-${var.environment}-s3-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_to_endpoints" {
  count = var.enabled ? 1 : 0

  security_group_id = var.ec2_security_group_id

  referenced_security_group_id = aws_security_group.endpoints[0].id

  description = "Allow application EC2 instances to access AWS VPC endpoints"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_to_s3" {
  count = var.enabled ? 1 : 0

  security_group_id = var.ec2_security_group_id
  prefix_list_id    = data.aws_prefix_list.s3.id

  description = "Allow application EC2 instances to access Amazon S3 over HTTPS"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}