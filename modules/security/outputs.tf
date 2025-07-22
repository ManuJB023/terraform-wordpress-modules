output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = var.create_key_pair ? aws_key_pair.main[0].key_name : null
}