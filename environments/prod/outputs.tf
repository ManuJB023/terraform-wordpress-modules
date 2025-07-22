# Production outputs using the correct output names from the WordPress module

output "website_url" {
  description = "URL of the WordPress site"
  value       = module.wordpress.load_balancer_url
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.wordpress.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer (for Route53 alias records)"
  value       = module.wordpress.load_balancer_zone_id
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.wordpress.database_endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.wordpress.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.wordpress.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.wordpress.private_subnet_ids
}

output "key_pair_name" {
  description = "Name of the EC2 key pair"
  value       = module.wordpress.key_pair_name
}

output "web_security_group_id" {
  description = "Web security group ID"
  value       = module.wordpress.web_security_group_id
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = module.wordpress.database_security_group_id
}