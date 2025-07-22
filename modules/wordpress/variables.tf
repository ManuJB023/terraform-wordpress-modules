# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Security Configuration
variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_key_pair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = true
}

variable "public_key" {
  description = "Public key for EC2 key pair (required if create_key_pair is true)"
  type        = string
  default     = ""
}

variable "existing_key_name" {
  description = "Name of existing key pair to use (used if create_key_pair is false)"
  type        = string
  default     = ""
}

# Database Configuration
variable "db_name" {
  description = "Name of the WordPress database"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database in GB"
  type        = number
  default     = 20
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

# WordPress Configuration
variable "wp_title" {
  description = "WordPress site title"
  type        = string
  default     = "My WordPress Site"
}

variable "wp_admin" {
  description = "WordPress admin username"
  type        = string
  default     = "admin"
}

variable "wp_password" {
  description = "WordPress admin password"
  type        = string
  sensitive   = true
}

variable "wp_email" {
  description = "WordPress admin email"
  type        = string
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}