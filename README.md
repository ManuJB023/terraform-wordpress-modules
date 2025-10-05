# WordPress Terraform AWS Infrastructure

**Production-ready, modular WordPress deployment on AWS using Terraform**

![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D1.5.0-blue)
![AWS Provider](https://img.shields.io/badge/AWS-%3E%3D5.0-orange)
![PHP Version](https://img.shields.io/badge/PHP-8.2-purple)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

This repository provides production-tested Terraform modules for deploying highly available WordPress infrastructure on AWS. The architecture follows AWS Well-Architected Framework principles with emphasis on security, scalability, and cost optimization.

### Key Features

- **High Availability**: Multi-AZ deployment with Auto Scaling Groups (2-10 instances)
- **Load Balancing**: Application Load Balancer with health checks and session stickiness
- **Modern Stack**: PHP 8.2, Apache 2.4, WordPress latest, MySQL 8.0 (RDS)
- **Security**: VPC isolation, security groups, encrypted RDS, IAM best practices
- **Scalability**: CloudWatch-based auto-scaling on CPU metrics
- **Monitoring**: CloudWatch alarms for CPU, health checks, and scaling events
- **Portability**: No hardcoded values, fully parameterized configuration

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    VPC (10.x.0.0/16)                  │  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
│  │  │Public Subnet │  │Public Subnet │  │Private Sub. │ │  │
│  │  │    AZ-1      │  │    AZ-2      │  │   AZ-1/2    │ │  │
│  │  │              │  │              │  │             │ │  │
│  │  │  ┌────────┐  │  │  ┌────────┐  │  │ ┌─────────┐ │ │  │
│  │  │  │  ALB   │◄─┼──┼──│   EC2  │  │  │ │   RDS   │ │ │  │
│  │  │  │        │  │  │  │  ASG   │──┼──┼─│ MySQL   │ │ │  │
│  │  │  └────────┘  │  │  │ (2-10) │  │  │ │Multi-AZ │ │ │  │
│  │  │              │  │  └────────┘  │  │ └─────────┘ │ │  │
│  │  └──────────────┘  └──────────────┘  └─────────────┘ │  │
│  │                                                        │  │
│  │  Internet Gateway ──► NAT Gateway ──► Route Tables    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Infrastructure Components

| Module | Resources | Purpose |
|--------|-----------|---------|
| **VPC** | VPC, Subnets, IGW, Route Tables | Network isolation with public/private topology |
| **Security** | Security Groups, Key Pairs | Firewall rules for web, SSH, and database access |
| **Database** | RDS MySQL, Subnet Groups | Managed database with Multi-AZ, backups, encryption |
| **Compute** | ALB, ASG, Launch Template, CloudWatch | Auto-scaling WordPress instances with load balancing |

## Prerequisites

Before you begin, ensure you have:

- **AWS Account** with administrative or power user permissions
- **Terraform** >= 1.5.0 ([Download](https://www.terraform.io/downloads))
- **AWS CLI** configured with credentials ([Setup Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html))
- **SSH Key Pair** (optional, for EC2 access)
- **S3 Bucket** for Terraform state (recommended for production)

### AWS Permissions Required

Your IAM user/role needs permissions for:
- EC2 (instances, security groups, launch templates)
- VPC (subnets, route tables, internet gateways)
- RDS (database instances, subnet groups)
- ELB (application load balancers, target groups)
- Auto Scaling (groups, policies)
- CloudWatch (alarms, metrics)

## Quick Start

### 1. Clone and Setup

```bash
git clone <your-repository-url>
cd terraform-wordpress-modules/environments/prod
```

### 2. Configure Backend (Recommended)

Create an S3 bucket for state storage:

```bash
aws s3 mb s3://your-terraform-state-bucket-2025
aws dynamodb create-table \
  --table-name terraform-state-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Update `main.tf` backend configuration with your bucket name.

### 3. Create Configuration File

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Basic Configuration
aws_region   = "us-east-1"
project_name = "my-site"
environment  = "production"

# Network Access
allowed_ssh_cidrs = ["YOUR_IP/32"]  # Replace with your IP

# SSH Key (generate with: ssh-keygen -t ed25519)
create_key_pair = true
public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA..."

# Database Configuration
db_name     = "wordpress_prod"
db_username = "wp_admin"
db_password = "CHANGE_THIS_STRONG_PASSWORD_123!"

# WordPress Admin
wp_title    = "My Production Site"
wp_admin    = "admin"
wp_password = "CHANGE_THIS_STRONG_PASSWORD_456!"
wp_email    = "admin@yourdomain.com"

# Cost Management
cost_center  = "prod-web-001"
owner_email  = "devops@yourdomain.com"
```

### 4. Initialize and Deploy

```bash
# Initialize Terraform and download providers
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply

# Get WordPress URL
terraform output website_url
```

### 5. Complete WordPress Installation

1. Open the URL from `terraform output website_url`
2. You'll be redirected to `/wp-admin/install.php`
3. Complete the 5-minute installation wizard:
   - **Site Title**: (from wp_title)
   - **Username**: (from wp_admin)
   - **Password**: (from wp_password)
   - **Email**: (from wp_email)
4. Click "Install WordPress"
5. Log in and start building your site

## Configuration Options

### Scaling Configuration

Control your infrastructure size and scaling behavior:

```hcl
# Instance Configuration
instance_type    = "t3.medium"    # t3.small, t3.medium, t3.large
min_size         = 2              # Minimum instances (HA requires 2+)
max_size         = 10             # Maximum instances
desired_capacity = 3              # Initial instance count

# Database Configuration
db_instance_class    = "db.t3.medium"  # db.t3.small, db.r5.large, etc.
db_allocated_storage = 100             # GB
```

### Auto-Scaling Policies

The infrastructure includes automatic scaling:

- **Scale Up**: When average CPU > 70% for 4 minutes
- **Scale Down**: When average CPU < 20% for 4 minutes
- **Cooldown**: 5 minutes between scaling actions
- **Health Check**: 5-minute grace period for new instances

## Security Best Practices

### Production Security Checklist

- [ ] Use AWS Secrets Manager for passwords (not terraform.tfvars)
- [ ] Enable MFA on AWS account
- [ ] Restrict `allowed_ssh_cidrs` to specific IPs or use bastion host
- [ ] Enable VPC Flow Logs for network monitoring
- [ ] Use SSL/TLS certificates (add HTTPS listener to ALB)
- [ ] Enable RDS encryption at rest (configured by default)
- [ ] Regular security updates via Auto Scaling Group refresh
- [ ] Implement AWS WAF for application-level protection
- [ ] Use CloudTrail for API auditing

### Using AWS Secrets Manager

Store sensitive values securely:

```bash
# Store database password
aws secretsmanager create-secret \
  --name prod/wordpress/db_password \
  --secret-string "your-secure-password"

# Store WordPress admin password
aws secretsmanager create-secret \
  --name prod/wordpress/wp_password \
  --secret-string "your-secure-password"
```

Update `main.tf` to reference secrets:

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/wordpress/db_password"
}

module "wordpress" {
  # ...
  db_password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

## Monitoring and Maintenance

### Included CloudWatch Alarms

- **High CPU Usage**: Triggers when CPU > 70% (scale up)
- **Low CPU Usage**: Triggers when CPU < 20% (scale down)
- **Unhealthy Targets**: Alerts when instances fail health checks
- **Database Connections**: (optional) Monitor RDS connection limits

### View Logs

```bash
# Instance console output
aws ec2 get-console-output --instance-id i-xxxxx --output text

# Application logs (requires SSH access)
ssh -i your-key.pem ec2-user@INSTANCE_IP
sudo tail -f /var/log/httpd/error_log
sudo tail -f /var/log/user-data.log
```

### Updating WordPress

```bash
# Trigger rolling update of all instances
terraform apply -replace="module.wordpress.module.compute.aws_launch_template.wordpress"

# Or use AWS CLI
aws autoscaling start-instance-refresh \
  --auto-scaling-group-name my-site-prod-asg \
  --preferences MinHealthyPercentage=50
```

## Database Management

### Backup and Restore

RDS automated backups are enabled by default (7-day retention):

```bash
# Create manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier my-site-prod-database \
  --db-snapshot-identifier my-site-manual-backup-$(date +%Y%m%d)

# Restore from snapshot (requires new DB instance)
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier my-site-restored \
  --db-snapshot-identifier my-site-manual-backup-20251003
```

### Clear WordPress Database

To reset WordPress (for testing or reinstallation):

```bash
# Get database endpoint
DB_ENDPOINT=$(terraform output -raw database_endpoint)

# Connect and clear
mysql -h $DB_ENDPOINT -u wp_admin -p << EOF
DROP DATABASE IF EXISTS wordpress_prod;
CREATE DATABASE wordpress_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF
```

## Cost Optimization

### Estimated Monthly Costs

| Resource | Type | Quantity | Est. Cost/Month |
|----------|------|----------|----------------|
| EC2 Instances | t3.medium | 2-3 avg | $60-90 |
| Application Load Balancer | - | 1 | $25 |
| RDS MySQL | db.t3.medium | 1 Multi-AZ | $120 |
| EBS Storage | gp3 | 100 GB | $10 |
| Data Transfer | Outbound | ~100 GB | $9 |
| **Total** | | | **~$224-254/month** |

*Prices based on us-east-1 region, subject to change*

### Cost Reduction Strategies

```hcl
# Development/Testing: Reduce instance sizes
instance_type        = "t3.small"    # ~$15/month per instance
db_instance_class    = "db.t3.small" # ~$30/month (Single-AZ)
min_size            = 1
max_size            = 2
desired_capacity    = 1

# Enable auto-shutdown for non-prod
# Use AWS Instance Scheduler or Lambda
```

### Budget Alerts

Set up AWS Budget alerts:

```bash
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget-config.json \
  --notifications-with-subscribers file://notifications.json
```

## Complete Cleanup (IMPORTANT)

**⚠️ This will permanently delete all resources and data. Ensure you have backups!**

### Step 1: Create Final Backup

```bash
# Backup database
aws rds create-db-snapshot \
  --db-instance-identifier $(terraform output -raw database_endpoint | cut -d: -f1) \
  --db-snapshot-identifier final-backup-$(date +%Y%m%d-%H%M)

# Export WordPress files (requires access to EC2 instance)
# Files are lost when instances terminate - consider EFS for shared storage
```

### Step 2: Destroy Infrastructure

```bash
# Review what will be deleted
terraform plan -destroy

# Destroy all resources
terraform destroy

# Confirm by typing: yes
```

### Step 3: Clean Up State Files

```bash
# If using local state
rm -rf .terraform
rm terraform.tfstate*
rm .terraform.lock.hcl

# If using S3 backend, optionally delete state bucket
aws s3 rb s3://your-terraform-state-bucket-2025 --force
aws dynamodb delete-table --table-name terraform-state-locks
```

### Step 4: Verify Cleanup

Check for remaining resources:

```bash
# Check EC2 instances
aws ec2 describe-instances --filters "Name=tag:Project,Values=my-site" \
  --query "Reservations[].Instances[].[InstanceId,State.Name]"

# Check RDS instances
aws rds describe-db-instances --query "DBInstances[].[DBInstanceIdentifier,DBInstanceStatus]"

# Check load balancers
aws elbv2 describe-load-balancers --query "LoadBalancers[].[LoadBalancerName,State.Code]"

# Check VPCs
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=my-site" \
  --query "Vpcs[].[VpcId,Tags[?Key=='Name'].Value|[0]]"
```

### Step 5: Review Costs

```bash
# Check for any remaining charges
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE
```

### Common Cleanup Issues

**Problem**: `terraform destroy` fails with dependency errors

**Solution**:
```bash
# Manually terminate instances first
aws autoscaling set-desired-capacity --auto-scaling-group-name my-site-prod-asg --desired-capacity 0
sleep 60

# Then retry destroy
terraform destroy
```

**Problem**: RDS instance in "deleting" state

**Solution**: RDS deletion can take 5-10 minutes. Final snapshot is created automatically (unless disabled).

**Problem**: VPC won't delete due to ENIs

**Solution**: Wait 5 minutes for ENIs to detach, or manually delete network interfaces in the AWS Console.

## Troubleshooting

### Health Check Failures

```bash
# Check target health
aws elbv2 describe-target-health --target-group-arn <TG_ARN>

# Check instance console output
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=my-site-prod-asg" --query "Reservations[0].Instances[0].InstanceId" --output text)
aws ec2 get-console-output --instance-id $INSTANCE_ID --output text | tail -100
```

### WordPress 500 Errors

Common causes:
1. **PHP Version**: Ensure PHP 8.2 is installed (not PHP 5.4)
2. **Database Connection**: Verify RDS endpoint and credentials
3. **File Permissions**: Check apache:apache ownership
4. **wp-config.php**: Validate syntax with `php -l wp-config.php`

### Cannot Connect to Database

```bash
# Test database connectivity from instance
mysql -h DATABASE_ENDPOINT -u wp_admin -p -e "SELECT 1;"

# Check security group rules
aws ec2 describe-security-groups --group-ids <DB_SG_ID>
```

## Production Enhancements

### Add HTTPS Support

1. Request SSL certificate in AWS Certificate Manager
2. Add HTTPS listener to ALB:

```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.wordpress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:region:account:certificate/xxx"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}
```

### Add CloudFront CDN

Distribute static assets globally:

```hcl
resource "aws_cloudfront_distribution" "wordpress" {
  origin {
    domain_name = aws_lb.wordpress.dns_name
    origin_id   = "wordpress-alb"
  }
  # ... additional CloudFront configuration
}
```

### Implement Shared Storage

Use EFS for wp-content/uploads across instances:

```hcl
resource "aws_efs_file_system" "wordpress" {
  encrypted = true
  tags = { Name = "wordpress-content" }
}
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Test changes in a dev environment
4. Update documentation
5. Submit a pull request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Support and Resources

- **Issues**: [GitHub Issues](https://github.com/your-org/repo/issues)
- **Documentation**: [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- **Terraform**: [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **WordPress**: [WordPress Codex](https://codex.wordpress.org/)

---

**⚠️ Security Notice**: Never commit sensitive data (passwords, private keys, access tokens) to version control. Use AWS Secrets Manager, environment variables, or encrypted Terraform state for production deployments.

**💰 Cost Awareness**: This infrastructure incurs ongoing AWS charges. Always run `terraform destroy` when testing is complete to avoid unnecessary costs.

**Author: Manuel Bauka**