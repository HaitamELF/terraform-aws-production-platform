output "ssm_endpoint_id" {
  description = "ID of the SSM VPC endpoint"
  value       = var.enabled ? aws_vpc_endpoint.ssm[0].id : null
}

output "ssmmessages_endpoint_id" {
  description = "ID of the SSM Messages VPC endpoint"
  value       = var.enabled ? aws_vpc_endpoint.ssmmessages[0].id : null
}

output "monitoring_endpoint_id" {
  description = "ID of the CloudWatch Monitoring VPC endpoint"
  value       = var.enabled ? aws_vpc_endpoint.monitoring[0].id : null
}

output "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  value       = var.enabled ? aws_vpc_endpoint.logs[0].id : null
}

output "s3_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint"
  value       = var.enabled ? aws_vpc_endpoint.s3[0].id : null
}