resource "aws_security_group" "alb" {
  name        = "${var.name}-${var.environment}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.name}-${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP traffic from the Internet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ec2" {
  security_group_id = aws_security_group.alb.id

  description = "Allow ALB traffic to application instances"

  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = var.application_port
  ip_protocol                  = "tcp"
  to_port                      = var.application_port
}

resource "aws_security_group" "ec2" {
  name        = "${var.name}-${var.environment}-ec2-sg"
  description = "Security group for application EC2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.name}-${var.environment}-ec2-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  security_group_id = aws_security_group.ec2.id

  description = "Allow application traffic from ALB"

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.application_port
  ip_protocol                  = "tcp"
  to_port                      = var.application_port
}