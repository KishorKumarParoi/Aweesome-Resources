# Advanced Terraform: Multi-Cloud, Modules, Workspaces & Testing

I'll teach you a complete production-grade setup with practical examples. Let me structure this progressively.

---

## Part 1: Project Structure with Modules

### Recommended Directory Layout
```
terraform/
├── modules/
│   ├── aws/
│   │   ├── eks/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── vpc.tf
│   │   ├── networking/
│   │   └── security/
│   ├── azure/
│   │   ├── aks/
│   │   └── networking/
│   ├── gcp/
│   │   ├── gke/
│   │   └── networking/
│   └── kubernetes/
│       ├── deployments/
│       ├── services/
│       └── namespaces/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── tests/
│   ├── unit/
│   └── integration/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

---

## Part 2: Multi-Cloud Setup

### 2.1 Provider Configuration (main.tf)
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.28"
    }
  }

  # Remote state with S3 backend
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "multicloud/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# Azure Provider
provider "azurerm" {
  features {}
  
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

# GCP Provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Kubernetes Provider (will use EKS, AKS, or GKE)
provider "kubernetes" {
  host                   = var.k8s_host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_ca_certificate)
}
```

---

## Part 3: Comprehensive Variables Setup

### 3.1 variables.tf
```hcl
# Global Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# Multi-Cloud Selection
variable "cloud_provider" {
  description = "Primary cloud provider"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be aws, azure, or gcp."
  }
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Azure Variables
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_region" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# GCP Variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

# Kubernetes Variables
variable "k8s_host" {
  description = "Kubernetes API endpoint"
  type        = string
  sensitive   = true
}

variable "k8s_token" {
  description = "Kubernetes API token"
  type        = string
  sensitive   = true
}

variable "k8s_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  type        = string
  sensitive   = true
}

# Cluster Configuration
variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 100
    error_message = "Node count must be between 1 and 100."
  }
}

variable "node_instance_type" {
  description = "Node instance type"
  type        = string
  default     = "t3.large"
}

# Networking
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Tagging
variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Feature Flags
variable "enable_monitoring" {
  description = "Enable CloudWatch/Prometheus monitoring"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable cluster logging"
  type        = bool
  default     = true
}

variable "enable_autoscaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = true
}

variable "autoscaling_max_nodes" {
  description = "Maximum nodes for autoscaling"
  type        = number
  default     = 10
}
```

### 3.2 terraform.tfvars (Environment-Specific)
```hcl
# Global
environment    = "dev"
project_name   = "awesome-resources"
cloud_provider = "aws"

# AWS
aws_region = "us-east-1"
aws_zones  = ["us-east-1a", "us-east-1b"]

# Cluster
cluster_name          = "kkp-cluster-dev"
cluster_version       = "1.28"
node_count            = 2
node_instance_type    = "t3.medium"

# Networking
vpc_cidr     = "10.0.0.0/16"
subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]

# Features
enable_monitoring     = true
enable_logging        = true
enable_autoscaling    = true
autoscaling_max_nodes = 5

# Tags
tags = {
  Team       = "Platform"
  CostCenter = "Engineering"
  Owner      = "KKP"
}
```

---

## Part 4: Module Examples

### 4.1 AWS EKS Module (modules/aws/eks/main.tf)
```hcl
# modules/aws/eks/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.aws_zones[count.index % length(var.aws_zones)]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                                      = "${var.cluster_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# NAT Gateway for Private Subnets
resource "aws_eip" "nat" {
  count  = var.enable_private_subnets ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eip"
  })

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_private_subnets ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat"
  })

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.cluster_name}-"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-cluster-sg"
  })
}

# Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.cluster_name}-nodes-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nodes-sg"
  })
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name_prefix = "${var.cluster_name}-cluster-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# IAM Role for EKS Nodes
resource "aws_iam_role" "eks_nodes" {
  name_prefix = "${var.cluster_name}-nodes-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_instance_profile" "eks_nodes" {
  name_prefix = "${var.cluster_name}-nodes-"
  role        = aws_iam_role.eks_nodes.name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = aws_subnet.public[*].id
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = var.enable_logging ? [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ] : []

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_route_table_association.public
  ]
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.public[*].id
  version         = var.cluster_version

  scaling_config {
    desired_size = var.node_count
    max_size     = var.enable_autoscaling ? var.autoscaling_max_nodes : var.node_count
    min_size     = 1
  }

  instance_types = [var.node_instance_type]

  vpc_config {
    security_groups = [aws_security_group.eks_nodes.id]
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy
  ]
}

# EBS CSI Driver Addon (for persistent volumes)
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs.version
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  tags = var.tags
}

# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi_driver" {
  name_prefix = "${var.cluster_name}-ebs-csi-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_eks_addon_version" "ebs" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.cluster_version
  most_recent        = true
}
```

### 4.2 AWS EKS Module Variables (modules/aws/eks/variables.tf)
```hcl
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
  default     = 3
}

variable "node_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.large"
}

variable "enable_autoscaling" {
  description = "Enable autoscaling"
  type        = bool
  default     = true
}

variable "autoscaling_max_nodes" {
  description = "Maximum nodes"
  type        = number
  default     = 10
}

variable "enable_private_subnets" {
  description = "Create private subnets"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable EKS logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

### 4.3 AWS EKS Module Outputs (modules/aws/eks/outputs.tf)
```hcl
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Cluster CA certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "node_security_group_id" {
  description = "Node security group ID"
  value       = aws_security_group.eks_nodes.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
}
```

---

## Part 5: Kubernetes Module

### 5.1 Kubernetes Namespace Module (modules/kubernetes/namespace/main.tf)
```hcl
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.28"
    }
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = var.namespace_name

    labels = {
      name        = var.namespace_name
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

# Service Account for applications
resource "kubernetes_service_account" "main" {
  count = var.create_service_account ? 1 : 0

  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace.main.metadata[0].name

    labels = {
      app = var.service_account_name
    }
  }
}

# Network Policy for namespace isolation
resource "kubernetes_network_policy" "main" {
  count = var.enable_network_policy ? 1 : 0

  metadata {
    name      = "${var.namespace_name}-network-policy"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = var.namespace_name
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {}
      }
    }

    egress {
      to {
        pod_selector {}
      }
    }
  }
}

# Resource Quota
resource "kubernetes_resource_quota" "main" {
  count = var.enable_resource_quota ? 1 : 0

  metadata {
    name      = "${var.namespace_name}-quota"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    hard = {
      requests_cpu       = var.cpu_quota
      requests_memory    = var.memory_quota
      limits_cpu         = var.cpu_limit
      limits_memory      = var.memory_limit
      pods               = var.pod_quota
      services_nodeports = var.nodeport_quota
    }
  }
}

# Limit Range
resource "kubernetes_limit_range" "main" {
  count = var.enable_limit_range ? 1 : 0

  metadata {
    name      = "${var.namespace_name}-limits"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    limit {
      type = "Pod"

      max = {
        cpu    = var.pod_max_cpu
        memory = var.pod_max_memory
      }

      min = {
        cpu    = var.pod_min_cpu
        memory = var.pod_min_memory
      }
    }

    limit {
      type = "Container"

      max = {
        cpu    = var.container_max_cpu
        memory = var.container_max_memory
      }

      min = {
        cpu    = var.container_min_cpu
        memory = var.container_min_memory
      }

      default = {
        cpu    = var.container_default_cpu
        memory = var.container_default_memory
      }

      default_request = {
        cpu    = var.container_request_cpu
        memory = var.container_request_memory
      }
    }
  }
}
```

### 5.2 Kubernetes Namespace Module Variables (modules/kubernetes/namespace/variables.tf)
```hcl
variable "namespace_name" {
  description = "Kubernetes namespace name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "create_service_account" {
  description = "Create service account"
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "Service account name"
  type        = string
  default     = "default"
}

variable "enable_network_policy" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "enable_resource_quota" {
  description = "Enable resource quota"
  type        = bool
  default     = true
}

variable "cpu_quota" {
  description = "Total CPU requests quota"
  type        = string
  default     = "100"
}

variable "memory_quota" {
  description = "Total memory requests quota"
  type        = string
  default     = "100Gi"
}

variable "cpu_limit" {
  description = "Total CPU limits"
  type        = string
  default     = "200"
}

variable "memory_limit" {
  description = "Total memory limits"
  type        = string
  default     = "200Gi"
}

variable "pod_quota" {
  description = "Maximum pods"
  type        = string
  default     = "100"
}

variable "nodeport_quota" {
  description = "Maximum NodePort services"
  type        = string
  default     = "10"
}

variable "enable_limit_range" {
  description = "Enable limit range"
  type        = bool
  default     = true
}

variable "pod_max_cpu" {
  description = "Max CPU per pod"
  type        = string
  default     = "4"
}

variable "pod_max_memory" {
  description = "Max memory per pod"
  type        = string
  default     = "8Gi"
}

variable "pod_min_cpu" {
  description = "Min CPU per pod"
  type        = string
  default     = "100m"
}

variable "pod_min_memory" {
  description = "Min memory per pod"
  type        = string
  default     = "128Mi"
}

variable "container_max_cpu" {
  description = "Max CPU per container"
  type        = string
  default     = "2"
}

variable "container_max_memory" {
  description = "Max memory per container"
  type        = string
  default     = "4Gi"
}

variable "container_min_cpu" {
  description = "Min CPU per container"
  type        = string
  default     = "50m"
}

variable "container_min_memory" {
  description = "Min memory per container"
  type        = string
  default     = "64Mi"
}

variable "container_default_cpu" {
  description = "Default CPU per container"
  type        = string
  default     = "500m"
}

variable "container_default_memory" {
  description = "Default memory per container"
  type        = string
  default     = "512Mi"
}

variable "container_request_cpu" {
  description = "Default request CPU"
  type        = string
  default     = "250m"
}

variable "container_request_memory" {
  description = "Default request memory"
  type        = string
  default     = "256Mi"
}
```

---

## Part 6: Workspaces for Environment Management

### 6.1 Using Workspaces
```bash
# Create separate workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspaces
terraform workspace select dev

# List workspaces
terraform workspace list

# Plan/Apply for specific workspace
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### 6.2 Workspace-Aware Configuration (main.tf)
```hcl
# Use workspace name for naming
locals {
  workspace_name = terraform.workspace
  
  # Different settings per environment
  environment_config = {
    dev = {
      node_count             = 2
      instance_type          = "t3.medium"
      enable_monitoring      = false
      autoscaling_max_nodes  = 5
    }
    staging = {
      node_count             = 3
      instance_type          = "t3.large"
      enable_monitoring      = true
      autoscaling_max_nodes  = 10
    }
    prod = {
      node_count             = 5
      instance_type          = "t3.xlarge"
      enable_monitoring      = true
      autoscaling_max_nodes  = 20
    }
  }

  current_env = lookup(local.environment_config, local.workspace_name, local.environment_config["dev"])
}

# Override node count based on workspace
module "eks" {
  source = "./modules/aws/eks"

  cluster_name          = "${var.cluster_name}-${local.workspace_name}"
  node_count            = local.current_env.node_count
  node_instance_type    = local.current_env.instance_type
  autoscaling_max_nodes = local.current_env.autoscaling_max_nodes
  enable_monitoring     = local.current_env.enable_monitoring

  # ... other variables
}
```

---

## Part 7: Complete Main Configuration

### 7.1 Root main.tf (All Clouds)
```hcl
# All cloud setup
locals {
  environment = var.environment
  workspace   = terraform.workspace
}

# AWS EKS Cluster
module "aws_eks" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "./modules/aws/eks"

  cluster_name          = var.cluster_name
  cluster_version       = var.cluster_version
  vpc_cidr              = var.vpc_cidr
  subnet_cidrs          = var.subnet_cidrs
  aws_zones             = var.aws_zones
  node_count            = var.node_count
  node_instance_type    = var.node_instance_type
  enable_autoscaling    = var.enable_autoscaling
  autoscaling_max_nodes = var.autoscaling_max_nodes
  enable_logging        = var.enable_logging

  tags = merge(var.tags, {
    CloudProvider = "AWS"
  })
}

# Azure AKS (similar structure)
# module "azure_aks" {
#   count  = var.cloud_provider == "azure" ? 1 : 0
#   source = "./modules/azure/aks"
#   ...
# }

# GCP GKE (similar structure)
# module "gcp_gke" {
#   count  = var.cloud_provider == "gcp" ? 1 : 0
#   source = "./modules/gcp/gke"
#   ...
# }

# Kubernetes Namespaces
module "k8s_namespace_apps" {
  source = "./modules/kubernetes/namespace"

  namespace_name      = "apps"
  environment         = var.environment
  create_service_account = true
  service_account_name = "apps-sa"
  enable_resource_quota = true
  cpu_quota            = "50"
  memory_quota         = "50Gi"

  # Use appropriate K8s provider
  depends_on = [module.aws_eks]
}

module "k8s_namespace_monitoring" {
  source = "./modules/kubernetes/namespace"

  namespace_name       = "monitoring"
  environment          = var.environment
  create_service_account = true
  service_account_name = "prometheus"
  enable_resource_quota = true
  cpu_quota            = "10"
  memory_quota         = "20Gi"

  depends_on = [module.aws_eks]
}
```

### 7.2 Root outputs.tf
```hcl
# AWS Outputs
output "aws_eks_cluster_id" {
  description = "AWS EKS cluster ID"
  value       = try(module.aws_eks[0].cluster_id, null)
}

output "aws_eks_endpoint" {
  description = "AWS EKS endpoint"
  value       = try(module.aws_eks[0].cluster_endpoint, null)
}

output "aws_eks_certificate_authority" {
  description = "AWS EKS certificate authority"
  value       = try(base64decode(module.aws_eks[0].cluster_certificate_authority_data), null)
  sensitive   = true
}

output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = try(module.aws_eks[0].vpc_id, null)
}

# Connection info for kubectl
output "kubernetes_connection_info" {
  description = "kubectl connection information"
  value = {
    host                   = try(module.aws_eks[0].cluster_endpoint, null)
    cluster_ca_certificate = try(module.aws_eks[0].cluster_certificate_authority_data, null)
    token                  = "Use AWS CLI: aws eks get-token --cluster-name ${var.cluster_name}"
  }
  sensitive = true
}

# Workspace info
output "current_workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
```

---

## Part 8: Testing with Terraform

### 8.1 Unit Tests with Terraform Cloud/Local State

**tests/unit/eks_module_test.tf**
```hcl
# Test: EKS cluster is configured correctly
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "test_enabled" {
  default = true
}

# Import module for testing
module "eks_test" {
  source = "../../modules/aws/eks"

  cluster_name          = "test-cluster"
  cluster_version       = "1.28"
  vpc_cidr              = "10.0.0.0/16"
  subnet_cidrs          = ["10.0.1.0/24", "10.0.2.0/24"]
  aws_zones             = ["us-east-1a", "us-east-1b"]
  node_count            = 2
  node_instance_type    = "t3.medium"
  enable_autoscaling    = true
  autoscaling_max_nodes = 5

  tags = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

# Assertions
output "cluster_version_is_valid" {
  value = module.eks_test.cluster_version == "1.28"
}

output "vpc_exists" {
  value = module.eks_test.vpc_id != null
}

output "subnets_created" {
  value = length(module.eks_test.subnet_ids) == 2
}
```

### 8.2 Integration Tests with Terratest (Go)

**tests/integration/eks_test.go**
```go
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/kubernetes"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEKSCluster(t *testing.T) {
	// Generate unique cluster name
	expectedClusterName := "test-" + random.UniqueId()

	// Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
		Vars: map[string]interface{}{
			"cluster_name":   expectedClusterName,
			"environment":    "test",
			"cloud_provider": "aws",
			"aws_region":     "us-east-1",
			"node_count":     2,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	clusterEndpoint := terraform.Output(t, terraformOptions, "aws_eks_endpoint")
	clusterID := terraform.Output(t, terraformOptions, "aws_eks_cluster_id")

	// Assertions
	assert.NotEmpty(t, clusterEndpoint, "Cluster endpoint should not be empty")
	assert.NotEmpty(t, clusterID, "Cluster ID should not be empty")
	assert.Equal(t, expectedClusterName, clusterID)

	// Test kubectl access
	kubeConfig := &kubernetes.KubectlOptions{
		ContextName: clusterID,
	}

	// Verify nodes are running
	nodes := kubernetes.GetNodes(t, kubeConfig)
	assert.Equal(t, 2, len(nodes), "Should have 2 nodes")

	// Verify namespaces exist
	namespaces := kubernetes.GetNamespaces(t, kubeConfig)
	assert.Contains(t, namespaces, "apps", "apps namespace should exist")
	assert.Contains(t, namespaces, "monitoring", "monitoring namespace should exist")
}

func TestKubernetesResources(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../../",
	}

	terraform.InitAndApply(t, terraformOptions)

	kubeConfig := &kubernetes.KubectlOptions{
		ContextName: terraform.Output(t, terraformOptions, "aws_eks_cluster_id"),
	}

	// Test resource quotas
	appNamespace := kubernetes.GetNamespace(t, kubeConfig, "apps")
	assert.NotNil(t, appNamespace, "apps namespace should exist")

	// Test network policies
	networkPolicies := kubernetes.GetNetworkPolicies(t, kubeConfig, "apps")
	assert.True(t, len(networkPolicies) > 0, "Network policies should be created")
}
```

### 8.3 Policy as Code - Sentinel

**tests/policy/aws_eks.sentinel**
```hcl
# Require minimum node count for production
import "tfplan/v2" as tfplan

# Find all EKS node groups
node_groups = filter tfplan.resource_changes as _, rc {
  rc.type == "aws_eks_node_group"
}

# Validate minimum node count for production
validate_node_count = rule when length(node_groups) > 0 {
  all node_groups as _, ng {
    ng.change.after.scaling_config[0].min_size >= 2
  }
}

# Require logging enabled
validate_logging = rule when length(node_groups) > 0 {
  all node_groups as _, ng {
    ng.change.after.tags["Environment"] != "prod" or
    ng.change.before.tags["Environment"] == null
  }
}

main = rule {
  validate_node_count and validate_logging
}
```

---

## Part 9: Advanced Patterns

### 9.1 Dynamic Blocks (DRY Principle)

```hcl
# Instead of repeating policy attachments...
# Use dynamic blocks:

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

# Dynamic security group rules
variable "security_group_rules" {
  type = list(object({
    ingress      = bool
    from_port    = number
    to_port      = number
    protocol     = string
    cidr_blocks  = list(string)
  }))
}

resource "aws_security_group_rule" "dynamic_rules" {
  for_each = { for idx, rule in var.security_group_rules : idx => rule }

  security_group_id = aws_security_group.main.id
  type              = each.value.ingress ? "ingress" : "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}
```

### 9.2 Conditional Resources

```hcl
# Only create in production
resource "aws_autoscaling_group" "prod_asg" {
  count = var.environment == "prod" ? 1 : 0
  # ... configuration
}

# Use module only for specific cloud
module "azure_aks" {
  count  = var.enable_azure ? 1 : 0
  source = "./modules/azure/aks"
}
```

### 9.3 Null Provider for Conditional Outputs

```hcl
# Safe output when resource may not exist
output "cluster_endpoint" {
  value = try(
    var.cloud_provider == "aws" ? module.aws_eks[0].cluster_endpoint : null,
    null
  )
}
```

---

## Part 10: CI/CD Integration

### 10.1 GitHub Actions Workflow

**.github/workflows/terraform.yml**
```yaml
name: Terraform CI/CD

on:
  push:
    branches: [main]
    paths-ignore:
      - "**.md"
  pull_request:
    branches: [main]

env:
  AWS_REGION: us-east-1
  TF_VERSION: 1.6.0

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init -backend=false

      - name: Terraform Validate
        run: terraform validate

      - name: TFLint
        uses: terraform-linters/setup-tflint@v3

      - name: Init TFLint
        run: tflint --init

      - name: Run TFLint
        run: tflint -f json

  plan:
    needs: validate
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -out=tfplan

      - name: Upload Plan
        uses: actions/upload-artifact@v3
        with:
          name: tfplan
          path: tfplan

  apply:
    needs: [validate, plan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_TO_ASSUME }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve
```

---

## Part 11: Practical Command Examples

```bash
# 1. INITIALIZATION
terraform init                              # Initialize working directory
terraform workspace new prod               # Create new workspace

# 2. VALIDATION & FORMATTING
terraform fmt -recursive                   # Format all files
terraform validate                         # Validate configuration
tflint                                     # Lint check

# 3. PLANNING WITH WORKSPACES
terraform workspace select prod
terraform plan -var-file="environments/prod/terraform.tfvars" -out=tfplan

# 4. APPLY
terraform apply tfplan

# 5. INSPECTION
terraform state list                       # List all resources
terraform state show module.aws_eks        # Show specific module
terraform output                           # Display all outputs
terraform output aws_eks_endpoint          # Specific output

# 6. DEBUGGING
terraform-graph                            # Visualize resource dependency
terraform plan -debug                      # Verbose output
TF_LOG=DEBUG terraform apply               # Full debug logging

# 7. TESTING
go test -v ./tests/integration

# 8. CLEANUP
terraform destroy -var-file="environments/dev/terraform.tfvars"

# 9. MULTI-WORKSPACE COMMANDS
terraform workspace list
terraform workspace show
terraform workspace delete old-workspace

# Multi-cloud deployment
terraform plan -var="cloud_provider=aws" -var-file="environments/prod/terraform.tfvars"
terraform plan -var="cloud_provider=azure" -var-file="environments/prod/terraform.tfvars"
```

---

## Key Takeaways

| Concept | Purpose |
|---------|---------|
| **Modules** | Reusable components, DRY code |
| **Workspaces** | Manage multiple environments |
| **Variables** | Parameterize configuration |
| **State** | Track resource changes |
| **Remote Backend** | Team collaboration & locking |
| **Testing** | Validate infrastructure code |
| **Sentinels** | Policy enforcement |
| **Dynamic Blocks** | Reduce repetition |
| **Null Provider** | Handle conditional outputs |

This structure scales to multi-cloud environments with proper testing, CI/CD, and environment separation!

Similar code found with 1 license type