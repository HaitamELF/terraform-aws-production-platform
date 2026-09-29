variable "name" {
  description = "Name prefix for security resources"
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
  description = "ID of the VPC where security groups are created"
  type        = string
}

variable "application_port" {
  description = "Port exposed by the application"
  type        = number
  default     = 8000

  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535
    error_message = "application_port must be between 1 and 65535."
  }
}

variable "endpoint_security_group_id" {
  description = "Security group ID attached to private VPC endpoints"
  type        = string
  default     = null
  nullable    = true
}