output "parameter_path" {
  description = "SSM Parameter Store namespace for application configuration"
  value       = "/${var.name}/${var.environment}/"
}

output "read_policy_arn" {
  description = "IAM policy ARN used to read application parameters"
  value       = aws_iam_policy.parameter_store_read.arn
}