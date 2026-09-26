output "ssm_endpoint_id" {
  description = "ID of the SSM VPC endpoint"
  value       = var.enabled ? aws_vpc_endpoint.ssm[0].id : null
}

output "ssmmessages_endpoint_id" {
  description = "ID of the SSM Messages VPC endpoint"
  value       = var.enabled ? aws_vpc_endpoint.ssmmessages[0].id : null
}