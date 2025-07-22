# WordPress Terraform AWS Infrastructure

**Production-ready WordPress deployment on AWS using Terraform modules**

![Terraform Version](https://img.shields.io/badge/terraform-%3E%3D1.5.0-blue)
![AWS Provider](https://img.shields.io/badge/AWS-%3E%3D5.0-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

This repository provides reusable Terraform modules for deploying scalable WordPress infrastructure on AWS. The modules follow infrastructure-as-code best practices and security standards suitable for production environments.

### Key Features

- **High Availability**: Auto Scaling Groups with Multi-AZ RDS deployment
- **Security**: Encrypted storage, IAM roles, restricted network access
- **Scalability**: Application Load Balancer with auto-scaling EC2 instances
- **Monitoring**: CloudWatch integration with health checks and alerting
- **Modular Design**: Reusable components for multiple environments

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                         VPC                             │
├─────────────────┬───────────────────┬───────────────────┤
│  Public Subnet  │  Public Subnet    │  Private Subnet   │
│                 │                   │                   │
│  ┌─────────┐   │  ┌─────────────┐  │  ┌─────────────┐  │
│  │   ALB   │   │  │ Auto Scaling │  │  │ RDS MySQL   │  │
│  │         │   │  │    Group     │  │  │ Multi-AZ    │  │
│  └─────────┘   │  └─────────────┘  │  └─────────────┘  │
└─────────────────┴───────────────────┴───────────────────┘
```

### Infrastructure Components

| Component | Purpose | Features |
|-----------|---------|----------|
| **VPC Module** | Network isolation | Public/private subnets, NAT Gateway, Internet Gateway |
| **Security Module** | Access control | Security groups, IAM roles, SSH restrictions |
| **Database Module** | Managed MySQL | RDS Multi-AZ, automated backups, encryption |
| **Compute Module** | WordPress hosting | Auto Scaling Groups, health checks, load balancing |

## Prerequisites

- AWS Account with appropriate IAM permissions
- Terraform >= 1.5.0
- AWS CLI configured (`aws configure`)
- SSH key pair for EC2 access

## Quick Start

### 1. Repository Setup

```bash
git clone https://github.com/your-org/terraform-wordpress-aws.git
cd terraform-wordpress-aws/environments/dev
```

### 2. Configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values:

```hcl
# terraform.tfvars
project_name       = "my-wordpress"
environment        = "dev"
allowed_ssh_cidrs  = ["203.0.113.0/32"]  # Replace with your IP
public_key         = "ssh-ed25519 AAAAC3..."  # Your SSH public key
db_password        = "your-secure-password"
wp_admin_password  = "your-wordpress-password"

# Optional: Customize instance types and capacity
instance_type      = "t3.medium"
min_size          = 1
max_size          = 3
desired_capacity  = 2
```

### 3. Deployment

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access Your WordPress Site

```bash
echo "WordPress URL: $(terraform output -raw load_balancer_url)"
```

## Security Best Practices

### Secrets Management

For production environments, use AWS Secrets Manager:

```hcl
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = "prod/wordpress/db_password"
}

locals {
  db_password = data.aws_secretsmanager_secret_version.db_credentials.secret_string
}
```

### Network Security

- Restrict SSH access to specific IP ranges or bastion hosts
- Use private subnets for database and application servers
- Enable VPC Flow Logs for network monitoring

### Monitoring and Alerting

The infrastructure includes CloudWatch alarms for:

- High CPU utilization (>80%)
- Database connection limits (>90%)
- Application Load Balancer health checks
- Auto Scaling Group health status

## Environment Management

The project supports multiple environments using separate Terraform workspaces:

```
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars.example
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars.example
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars.example
```

## Use Cases

- **Development/Staging**: Rapid environment provisioning for testing
- **Production Deployments**: Scalable WordPress hosting with high availability
- **Client Projects**: Template for consistent WordPress deployments
- **CI/CD Integration**: Automated infrastructure deployment in pipelines
- **Disaster Recovery**: Infrastructure-as-code enables quick rebuilds

## Cost Optimization

- Use `terraform plan` with cost estimation tools for budget planning
- Configure Auto Scaling policies based on actual usage patterns
- Consider using Spot Instances for non-production environments
- Implement automated shutdown schedules for development environments

## Maintenance and Updates

```bash
# Update Terraform modules
terraform get -update

# Plan infrastructure changes
terraform plan -out=plan.out

# Apply planned changes
terraform apply plan.out

# Clean up resources
terraform destroy
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions or issues:
- Create an issue in the GitHub repository
- Review the [Terraform AWS Provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Check [WordPress deployment best practices](https://wordpress.org/support/)

---

**⚠️ Important**: Never commit sensitive information like passwords or private keys to version control. Use AWS Secrets Manager or environment variables for production deployments.