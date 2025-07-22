# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.compute.load_balancer_dns_name
}

output "load_balancer_url" {
  description = "URL to access the WordPress site"
  value       = "http://${module.compute.load_balancer_dns_name}"
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer (for Route53 alias records)"
  value       = module.compute.load_balancer_zone_id
}

# Database Outputs
output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

# Security Group Outputs
output "web_security_group_id" {
  description = "Web security group ID"
  value       = module.security.web_security_group_id
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = module.security.database_security_group_id
}

# Key Pair Output
output "key_pair_name" {
  description = "Name of the EC2 key pair"
  value       = var.create_key_pair ? module.security.key_pair_name : var.existing_key_name
}