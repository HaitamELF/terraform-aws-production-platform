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