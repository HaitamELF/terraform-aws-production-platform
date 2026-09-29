variable "enabled" {
  description = "Whether SSM VPC endpoints should be created"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name prefix for VPC endpoint resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either dev or prod."
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets where interface endpoints are created"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "Security group ID used by EC2 instances"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "private_route_table_ids" {
  description = "Private route tables associated with the S3 gateway endpoint"
  type        = list(string)
}