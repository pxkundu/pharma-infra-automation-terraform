# EKS Module

This Terraform module creates an Amazon EKS cluster with managed node groups, following HIPAA/GDPR compliance requirements.

## Features

- EKS cluster with private endpoint access
- Managed node groups with auto-scaling
- KMS encryption for secrets and volumes
- IAM roles for service accounts (IRSA)
- Control plane logging
- Security groups for cluster and nodes
- HIPAA/GDPR compliant configurations

## Usage

```hcl
module "eks" {
  source = "git::https://gitlab.com/repo/modules/eks?ref=v1.0.0"

  project_name = "pharma-infra"
  environment  = "prod"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

  kubernetes_version = "1.27"
  enable_public_access = false

  node_desired_size = 2
  node_max_size     = 4
  node_min_size     = 1
  node_instance_types = ["t3.medium"]
  node_ami_id       = "ami-xxxxxxxxxxxxxxxxx"
  node_disk_size    = 20

  kms_key_arn = module.kms.key_arn

  tags = {
    Environment = "prod"
    Project     = "pharma-infra"
    ManagedBy   = "terraform"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | ~> 5.0 |
| kubernetes | ~> 2.0 |
| helm | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| vpc_id | VPC ID where the EKS cluster will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the EKS cluster | `list(string)` | n/a | yes |
| kubernetes_version | Kubernetes version | `string` | `"1.27"` | no |
| enable_public_access | Whether to enable public access to the EKS cluster | `bool` | `false` | no |
| cluster_ingress_cidrs | List of CIDR blocks allowed to access the EKS cluster | `list(string)` | `["10.0.0.0/8"]` | no |
| node_desired_size | Desired number of nodes in the node group | `number` | `2` | no |
| node_max_size | Maximum number of nodes in the node group | `number` | `4` | no |
| node_min_size | Minimum number of nodes in the node group | `number` | `1` | no |
| node_instance_types | List of instance types for the node group | `list(string)` | `["t3.medium"]` | no |
| node_ami_id | AMI ID for the node instances | `string` | n/a | yes |
| node_disk_size | Size of the root volume for node instances | `number` | `20` | no |
| kms_key_arn | ARN of the KMS key for encryption | `string` | n/a | yes |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | EKS cluster ID |
| cluster_arn | EKS cluster ARN |
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| cluster_iam_role_name | IAM role name of the EKS cluster |
| cluster_iam_role_arn | IAM role ARN of the EKS cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data required to communicate with the cluster |
| node_group_id | EKS node group ID |
| node_group_arn | Amazon Resource Name (ARN) of the EKS Node Group |
| node_group_status | Status of the EKS Node Group |
| node_group_role_name | IAM role name of the EKS Node Group |
| node_group_role_arn | IAM role ARN of the EKS Node Group |

## Security

This module implements several security best practices:

- Private endpoint access for the EKS cluster
- KMS encryption for secrets and volumes
- IAM roles for service accounts (IRSA)
- Control plane logging
- Security groups with least privilege
- HIPAA/GDPR compliant configurations

## Compliance

The module is designed to meet HIPAA/GDPR compliance requirements:

- Encrypted storage (EBS volumes, secrets)
- Audit logging (CloudWatch Logs, control plane logs)
- Network isolation (private subnets, security groups)
- Access control (IAM roles, security groups)
- Data protection (KMS encryption)

## License

MIT Licensed. See LICENSE for full details. 