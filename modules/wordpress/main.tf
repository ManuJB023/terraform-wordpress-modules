locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    db_host     = module.database.db_instance_endpoint  # Changed from var.db_host
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    wp_title    = var.wp_title
    wp_admin    = var.wp_admin
    wp_password = var.wp_password
    wp_email    = var.wp_email
  })
}

module "vpc" {
  source = "../vpc"

  project_name          = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = var.tags
}

module "security" {
  source = "../security"

  project_name      = var.project_name
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  create_key_pair   = var.create_key_pair
  public_key        = var.public_key
  tags             = var.tags
}

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
  
  tags = var.tags
}

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
  
  user_data = local.user_data
  
  tags = var.tags
  
  depends_on = [module.database]
}