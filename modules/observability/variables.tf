variable "name" {
  description = "Name prefix for observability resources"
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

variable "ec2_role_name" {
  description = "IAM role used by application EC2 instances"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days CloudWatch logs are retained"
  type        = number
  default     = 7

  validation {
    condition     = var.log_retention_days > 0
    error_message = "log_retention_days must be greater than zero."
  }
}

variable "compute_enabled" {
  description = "Whether compute resources are deployed"
  type        = bool
}

variable "instance_id" {
  description = "EC2 instance ID monitored by CloudWatch"
  type        = string
  default     = null
  nullable    = true
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the high CPU alarm"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alarm_threshold > 0 && var.cpu_alarm_threshold <= 100
    error_message = "cpu_alarm_threshold must be between 0 and 100."
  }
}