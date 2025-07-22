output "db_instance_endpoint" {
  description = "Database instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Database instance address"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Database instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "Database master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_id" {
  description = "Database instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "Database instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = aws_db_subnet_group.main.name
}