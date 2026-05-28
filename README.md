# EKS Terraform

AWS EKS (Elastic Kubernetes Service) cluster creation using Terraform. This repository provides Infrastructure as Code (IaC) configuration to deploy a production-ready Kubernetes cluster on AWS.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Repository Structure](#repository-structure)
- [Configuration Variables](#configuration-variables)
- [Getting Started](#getting-started)
- [Deployment](#deployment)
- [Outputs](#outputs)
- [Module Details](#module-details)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Overview

This Terraform configuration automates the creation of an AWS EKS cluster with the following components:

- **VPC (Virtual Private Cloud)**: Configured with public and private subnets across multiple availability zones
- **EKS Cluster**: Managed Kubernetes control plane
- **Node Groups**: Worker nodes for running containerized workloads
- **Security Groups**: Network access controls
- **IAM Roles**: Service account permissions

### Default Configuration

| Component | Default Value |
|-----------|---------------|
| AWS Region | `eu-north-1` |
| VPC CIDR | `10.0.0.0/16` |
| Kubernetes Version | `1.30` |
| Node Instance Type | `m7i-flex.large` |
| Node Group Capacity | ON_DEMAND |
| Desired Nodes | 2 |
| Min Nodes | 1 |
| Max Nodes | 4 |

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Terraform** (>= 1.0)
   - [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

2. **AWS CLI** (>= 2.0)
   - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

3. **kubectl** (>= 1.24)
   - [Installation Guide](https://kubernetes.io/docs/tasks/tools/)

4. **AWS Account** with appropriate IAM permissions

5. **AWS Credentials** configured locally
   ```bash
   aws configure
   ```

## Repository Structure

```
eks-terraform/
├── README.md                 # This file
├── main.tf                   # Main Terraform configuration
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── .gitignore                # Git ignore rules
├── backend/                  # Terraform backend configuration
└── modules/                  # Reusable Terraform modules
    ├── vpc/                  # VPC module
    ├── eks/                  # EKS cluster module
    └── ...
```

## Configuration Variables

All configurable parameters are defined in `variables.tf`. Below are the key variables:

### Network Configuration

```hcl
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
```

### Kubernetes Configuration

```hcl
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_groups" {
  description = "EKS node group configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
  }))
  default = {
    general = {
      instance_types = ["m7i-flex.large"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_size = 2
        max_size     = 4
        min_size     = 1
      }
    }
  }
}
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/sudhakarnallasre/eks-terraform.git
cd eks-terraform
```

### 2. Configure AWS Credentials

Ensure your AWS credentials are properly configured:

```bash
aws configure
# or set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-north-1"
```

### 3. Initialize Terraform

```bash
terraform init
```

This command initializes the Terraform working directory and downloads required providers and modules.

## Deployment

### Step 1: Review the Plan

```bash
terraform plan -out=tfplan
```

This generates an execution plan showing all resources that will be created.

### Step 2: Apply the Configuration

```bash
terraform apply tfplan
```

This creates the EKS cluster and all associated resources. The process typically takes 10-15 minutes.

### Step 3: Configure kubectl

After deployment completes, update your kubeconfig:

```bash
aws eks update-kubeconfig --region eu-north-1 --name my-eks-cluster
```

### Step 4: Verify the Cluster

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## Outputs

After successful deployment, Terraform will output the following values:

```hcl
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
```

Access these values using:

```bash
terraform output cluster_endpoint
terraform output cluster_name
terraform output vpc_id
```

## Module Details

### VPC Module

Creates a VPC with:
- Public and private subnets across availability zones
- NAT Gateways for private subnet outbound traffic
- Internet Gateway for public subnet access
- Route tables and associations

### EKS Module

Creates an EKS cluster with:
- Control plane with specified Kubernetes version
- IAM roles and policies
- Security groups
- Cluster logging (optional)
- Node groups with auto-scaling

## Customization

### Change AWS Region

Edit `variables.tf` or create a `terraform.tfvars` file:

```hcl
region = "us-east-1"
```

### Modify Cluster Name

```hcl
cluster_name = "my-production-cluster"
```

### Add Additional Node Groups

In `terraform.tfvars`:

```hcl
node_groups = {
  general = {
    instance_types = ["m7i-flex.large"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 2
      max_size     = 4
      min_size     = 1
    }
  }
  compute = {
    instance_types = ["c7i.xlarge"]
    capacity_type  = "SPOT"
    scaling_config = {
      desired_size = 1
      max_size     = 3
      min_size     = 0
    }
  }
}
```

### Update Kubernetes Version

```hcl
cluster_version = "1.31"
```

## Troubleshooting

### Issue: Terraform Init Fails

**Solution**: Ensure AWS credentials are properly configured and you have internet access.

```bash
aws sts get-caller-identity  # Verify AWS credentials
```

### Issue: Cluster Creation Times Out

**Solution**: Check AWS service limits in your region. Large deployments may require requesting limit increases.

### Issue: Nodes Not Ready

**Solution**: Check node security groups and IAM roles:

```bash
kubectl describe nodes
kubectl logs -n kube-system <pod-name>
```

### Issue: kubectl Cannot Connect to Cluster

**Solution**: Ensure kubeconfig is updated:

```bash
aws eks update-kubeconfig --region eu-north-1 --name my-eks-cluster
kubectl config current-context
```

## Cleanup

To destroy all resources and avoid AWS charges:

```bash
terraform destroy
```

Review the plan carefully before confirming destruction.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## Best Practices

- Always run `terraform plan` before applying changes
- Keep sensitive data out of version control
- Use remote state backend for team collaboration
- Document custom modifications
- Test changes in a non-production environment first
- Regularly update Kubernetes version
- Monitor cluster health and costs

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/best-practices)

## Support

For issues, questions, or suggestions, please open a GitHub Issue in this repository.
