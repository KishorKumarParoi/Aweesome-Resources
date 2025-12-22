# Terraform Infrastructure as Code 🏗️

Define, preview, and deploy infrastructure using Infrastructure as Code.

---

## What is Terraform?

Infrastructure as Code (IaC) tool that allows you to:
- Define infrastructure in HCL (HashiCorp Configuration Language)
- Plan changes before applying
- Version control infrastructure
- Easily replicate environments
- Manage multiple cloud providers

---

## Terraform Workflow

```
Write → Plan → Apply → Destroy
```

1. **Write** - Define infrastructure in .tf files
2. **Validate** - Check syntax
3. **Plan** - Preview changes
4. **Apply** - Create/update resources
5. **Destroy** - Remove infrastructure

---

## AWS Credentials Setup

⚠️ **NEVER commit credentials to version control!**

### Method 1: AWS CLI Configuration (Recommended)

```bash
# Interactive setup
aws configure

# When prompted:
# AWS Access Key ID: [your-key]
# AWS Secret Access Key: [your-secret]
# Default region: us-east-1
# Default output format: json

# Credentials stored in ~/.aws/credentials
cat ~/.aws/credentials
```

### Method 2: Environment Variables

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Add to ~/.bashrc for persistence
echo 'export AWS_ACCESS_KEY_ID="..."' >> ~/.bashrc
```

### Method 3: IAM Roles (Best for EC2)

```bash
# Attach IAM role to EC2 instance
# No credentials needed - automatically assumed!
# Go to EC2 console → Instance Settings → Attach IAM role
```

### Method 4: AWS SSO

```bash
aws sso login --profile your-profile

# Credentials automatically retrieved
```

---

## Basic Terraform Configuration

### Provider Setup

```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### EC2 Instance Example

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 22.04
  instance_type = "t2.micro"
  
  tags = {
    Name = "My Web Server"
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

---

## Terraform Commands

### Initialize

```bash
# Initialize Terraform (required first step)
terraform init

# Downloads provider plugins
# Creates .terraform directory
# Creates terraform.lock.hcl (dependency lock)
```

### Validate & Format

```bash
# Check syntax
terraform validate

# Format HCL code
terraform fmt

# Format recursively
terraform fmt -recursive
```

### Plan & Apply

```bash
# Show what will change
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Apply changes
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Apply specific plan file
terraform apply tfplan
```

### Destroy

```bash
# Remove all infrastructure
terraform destroy

# Destroy without confirmation
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=aws_instance.web
```

---

## Variables

### Define Variables

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "availability_zones" {
  description = "AZs for resources"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true  # Hide from output
}
```

### Use Variables

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
}
```

### Set Variable Values

```bash
# Via command line
terraform apply -var="instance_type=t2.small"

# Via variables file
terraform apply -var-file="vars.tfvars"

# Environment variables
export TF_VAR_instance_type="t2.medium"
terraform apply
```

### Variables File (vars.tfvars)

```hcl
instance_type = "t2.small"
region        = "us-west-2"
db_password   = "secure_password"
```

---

## Outputs

```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "instance_id" {
  value       = aws_instance.web.id
  description = "EC2 instance ID"
}

output "sensitive_data" {
  value       = aws_db_instance.db.password
  sensitive   = true
}
```

View outputs:
```bash
# Show all outputs
terraform output

# Show specific output
terraform output instance_ip

# Output as JSON
terraform output -json
```

---

## State Management

### Local State

```bash
# Terraform state is stored in terraform.tfstate (local)
# Contains sensitive information!
# Should NOT be committed to git

# .gitignore
terraform.tfstate
terraform.tfstate.*
.terraform/
```

### Remote State

```hcl
# Store state in S3
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Initialize remote state:
```bash
terraform init

# When prompted to migrate state:
# Answer "yes" to copy local state to S3
```

---

## State Commands

```bash
# List all resources in state
terraform state list

# Show specific resource details
terraform state show aws_instance.web

# Remove resource from state (without destroying)
terraform state rm aws_instance.web

# Move resource to different name
terraform state mv aws_instance.web aws_instance.new_web

# Replace provider/resource
terraform state replace-provider registry.terraform.io/-/aws registry.terraform.io/hashicorp/aws
```

---

## Modules

Reusable Terraform configurations.

### Module Structure

```
modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── ec2/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

### Use Module

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = "10.0.0.0/16"
  name       = "my-vpc"
}

module "ec2" {
  source = "./modules/ec2"
  
  instance_type = "t2.micro"
  vpc_id        = module.vpc.vpc_id
}
```

---

## Common Patterns

### Security Group

```hcl
resource "aws_security_group" "web" {
  name_prefix = "web-"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### IAM Role

```hcl
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
```

---

## Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG

# Save to file
export TF_LOG_PATH=terraform.log

# Run with verbose output
terraform plan -var-file=vars.tfvars -out=tfplan -no-color 2>&1 | tee output.log

# Console (interactive REPL)
terraform console
```

---

## Best Practices

✅ **Use remote state** - Team collaboration & durability
✅ **Lock state** - Prevent concurrent modifications
✅ **Use variables** - Reusable, environment-specific
✅ **Use modules** - DRY principle, reusability
✅ **Version providers** - Prevent unexpected upgrades
✅ **Plan before apply** - Review changes
✅ **Use .gitignore** - Never commit state/credentials
✅ **Sensitive outputs** - Mark sensitive data
✅ **Naming conventions** - Consistent resource names
✅ **Comments** - Document complex logic

---

**Last Updated:** December 22, 2025
