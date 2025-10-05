terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Configure remote state for production
  backend "s3" {
    bucket = "terraform-state-bucket-prod-2025"
    key    = "wordpress/prod/terraform.tfstate"
    region = "us-east-1"
    
    # Enable state locking
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  
  # Production-specific provider configuration
  default_tags {
    tags = {
      Environment = "production"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Create a local for common tags to avoid repetition
locals {
  common_tags = {
    Environment = "production"
    Project     = var.project_name
    CostCenter  = var.cost_center
    Owner       = var.owner_email
    Backup      = "required"
    Monitoring  = "enabled"
    ManagedBy   = "terraform"
  }
}

module "wordpress" {
  source = "../../modules/wordpress"

  project_name = "${var.project_name}-prod"
  
  # Production network configuration
  vpc_cidr             = "10.1.0.0/16"  # Different CIDR from dev
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
  
  # Enhanced security for production
  allowed_ssh_cidrs = var.allowed_ssh_cidrs  # Should be very restrictive
  create_key_pair   = var.create_key_pair
  public_key        = var.public_key
  existing_key_name = var.existing_key_name
  
  # Production database configuration
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = "db.r5.large"           # Production-grade instance
  db_allocated_storage = 100                     # More storage
  
  # High-availability compute configuration
  instance_type    = "t3.medium"                # Larger instances
  min_size         = 2                          # Always have 2 instances
  max_size         = 10                         # Can scale up to 10
  desired_capacity = 3                          # Start with 3 instances
  
  # WordPress configuration
  wp_title    = var.wp_title
  wp_admin    = var.wp_admin
  wp_password = var.wp_password
  wp_email    = var.wp_email
  
  # Production tags
  tags = local.common_tags
}