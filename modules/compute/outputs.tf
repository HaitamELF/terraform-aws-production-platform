output "instance_id" {
  description = "ID of the application EC2 instance"
  value       = var.enabled ? aws_instance.app[0].id : null
}

output "private_ip" {
  description = "Private IP address of the application EC2 instance"
  value       = var.enabled ? aws_instance.app[0].private_ip : null
}

output "ami_id" {
  description = "Amazon Linux AMI selected for the application instance"
  value       = data.aws_ami.amazon_linux.id
}