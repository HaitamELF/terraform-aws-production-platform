variable "project_name" {
  description = "Name used as a prefix for platform resources"
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

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region."
  }
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zone_count" {
  description = "Number of availability zones used by the platform"
  type        = number

  validation {
    condition     = var.availability_zone_count >= 2
    error_message = "At least two availability zones must be used."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to private subnets"
  type        = list(string)
}

variable "application_port" {
  description = "Port exposed by the application"
  type        = number

  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535
    error_message = "application_port must be between 1 and 65535."
  }
}

variable "instance_type" {
  description = "EC2 instance type used by application compute"
  type        = string
}

variable "compute_enabled" {
  description = "Whether application EC2 compute should be deployed"
  type        = bool
}

variable "vpc_endpoints_enabled" {
  description = "Whether private SSM VPC endpoints should be deployed"
  type        = bool
}

variable "log_retention_days" {
  description = "Number of days CloudWatch application logs are retained"
  type        = number

  validation {
    condition     = var.log_retention_days > 0
    error_message = "log_retention_days must be greater than zero."
  }
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the high CPU alarm"
  type        = number

  validation {
    condition     = var.cpu_alarm_threshold > 0 && var.cpu_alarm_threshold <= 100
    error_message = "cpu_alarm_threshold must be between 0 and 100."
  }
}