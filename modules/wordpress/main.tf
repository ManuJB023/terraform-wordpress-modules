# WordPress Module - Main Configuration
# This module orchestrates all components needed for a WordPress deployment

locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    # Strip the :3306 port from the RDS endpoint - MySQL client doesn't need it in hostname
    db_host     = split(":", module.database.db_instance_endpoint)[0]
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    wp_title    = var.wp_title
    wp_admin    = var.wp_admin
    wp_password = var.wp_password
    wp_email    = var.wp_email
  })
}

# VPC Module - Creates network infrastructure
module "vpc" {
  source = "../vpc"

  project_name          = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

# Security Module - Creates security groups and key pairs
module "security" {
  source = "../security"

  project_name      = var.project_name
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  create_key_pair   = var.create_key_pair
  public_key        = var.public_key
  tags             = var.tags
}

# Database Module - Creates RDS MySQL instance
module "database" {
  source = "../database"

  project_name        = var.project_name
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_ids  = [module.security.database_security_group_id]
  database_name       = var.db_name
  master_username     = var.db_username
  master_password     = var.db_password
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  tags                = var.tags
}

# Compute Module - Creates EC2 instances, ASG, and Load Balancer
module "compute" {
  source = "../compute"

  project_name       = var.project_name
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_ids = [module.security.web_security_group_id]
  key_name          = var.create_key_pair ? module.security.key_pair_name : var.existing_key_name
  instance_type     = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  user_data        = local.user_data
  tags             = var.tags

  # Ensure database is ready before launching instances
  depends_on = [module.database]
}
