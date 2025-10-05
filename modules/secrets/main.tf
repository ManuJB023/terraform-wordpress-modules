resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "wp_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}-${var.environment}-db-credentials"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "mysql"
    host     = var.db_endpoint
    dbname   = var.db_name
  })
}

resource "aws_secretsmanager_secret" "wp_credentials" {
  name = "${var.project_name}-${var.environment}-wp-credentials"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "wp_credentials" {
  secret_id = aws_secretsmanager_secret.wp_credentials.id
  secret_string = jsonencode({
    username = var.wp_username
    password = random_password.wp_password.result
    email    = var.wp_email
  })
}