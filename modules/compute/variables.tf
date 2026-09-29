variable "name" {
  description = "Name prefix for compute resources"
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

variable "subnet_id" {
  description = "Private subnet where the EC2 instance will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group attached to the EC2 instance"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile attached to the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enabled" {
  description = "Whether application compute resources should be created"
  type        = bool
  default     = false
}

variable "cloudwatch_namespace" {
  description = "CloudWatch namespace used by the CloudWatch Agent"
  type        = string
}

variable "aws_region" {
  description = "AWS region used by the EC2 bootstrap process"
  type        = string
}