output "application_log_group_name" {
  description = "Name of the application CloudWatch log group"
  value       = aws_cloudwatch_log_group.application.name
}

output "application_log_group_arn" {
  description = "ARN of the application CloudWatch log group"
  value       = aws_cloudwatch_log_group.application.arn
}

output "cloudwatch_logs_policy_arn" {
  description = "IAM policy allowing the application to write CloudWatch logs"
  value       = aws_iam_policy.cloudwatch_logs.arn
}

output "high_cpu_alarm_name" {
  description = "Name of the EC2 high CPU alarm"
  value       = var.compute_enabled ? aws_cloudwatch_metric_alarm.high_cpu[0].alarm_name : null
}

output "status_check_alarm_name" {
  description = "Name of the EC2 status check alarm"
  value       = var.compute_enabled ? aws_cloudwatch_metric_alarm.status_check_failed[0].alarm_name : null
}

output "cloudwatch_metrics_policy_arn" {
  description = "IAM policy allowing instances to publish CloudWatch metrics"
  value       = aws_iam_policy.cloudwatch_metrics.arn
}