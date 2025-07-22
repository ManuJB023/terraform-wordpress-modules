variable "aws_region" {
  description = "AWS region for production deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name cannot be empty."
  }
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH (should be very restrictive for production)"
  type        = list(string)
  default     = []  # No SSH access by default in production
  validation {
    condition     = length(var.allowed_ssh_cidrs) == 0 || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.allowed_ssh_cidrs[0]))
    error_message = "SSH CIDR blocks must be in valid CIDR format (e.g., 10.0.0.0/8)."
  }
}

variable "create_key_pair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for EC2 access (if creating new key pair)"
  type        = string
  default     = ""
}

variable "existing_key_name" {
  description = "Name of existing key pair to use"
  type        = string
  default     = ""
}

# Database variables
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "wordpress_prod"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "wp_admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_password) >= 12
    error_message = "Database password must be at least 12 characters long for production."
  }
}

# WordPress variables
variable "wp_title" {
  description = "WordPress site title"
  type        = string
  default     = "Production WordPress Site"
}

variable "wp_admin" {
  description = "WordPress admin username"
  type        = string
  default     = "wp_admin"
}

variable "wp_password" {
  description = "WordPress admin password"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.wp_password) >= 12
    error_message = "WordPress password must be at least 12 characters long for production."
  }
}

variable "wp_email" {
  description = "WordPress admin email address"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.wp_email))
    error_message = "WordPress email must be a valid email address."
  }
}

# Production-specific variables
variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "production"
}

variable "owner_email" {
  description = "Email of the system owner"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.owner_email))
    error_message = "Owner email must be a valid email address."
  }
}