terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "wordpress" {
  source = "../../modules/wordpress"

  project_name = "${var.project_name}-dev"
  
  # Network configuration
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  # Security
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  create_key_pair   = true
  public_key        = var.public_key
  
  # Database
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = "db.t3.micro"
  
  # Compute
  instance_type    = "t3.micro"
  min_size        = 1
  max_size        = 2
  desired_capacity = 1
  
  # WordPress
  wp_title    = var.wp_title
  wp_admin    = var.wp_admin
  wp_password = var.wp_password
  wp_email    = var.wp_email
  
  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}