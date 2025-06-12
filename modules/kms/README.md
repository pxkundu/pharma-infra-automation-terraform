# KMS Module

This Terraform module creates a KMS key for encryption with appropriate IAM policies for EKS and CloudWatch Logs integration.

## Features

- KMS key with automatic rotation
- KMS alias for easy reference
- IAM policies for:
  - EKS cluster encryption
  - CloudWatch Logs encryption
  - Root account access
- HIPAA/GDPR compliant configuration

## Usage

```hcl
module "kms" {
  source = "git::https://gitlab.com/repo/modules/kms?ref=v1.0.0"

  project_name = "pharma-infra"
  environment  = "prod"
  description  = "KMS key for EKS cluster encryption"

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Project name for resource naming | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| description | Description of the KMS key | `string` | `"KMS key for EKS cluster encryption"` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key_id | The globally unique identifier for the key |
| key_arn | The Amazon Resource Name (ARN) of the key |
| alias_name | The display name of the alias |
| alias_arn | The Amazon Resource Name (ARN) of the key alias |

## Security

This module implements several security best practices:

- Automatic key rotation
- Least privilege IAM policies
- Service-specific permissions
- Audit logging through CloudWatch

## Compliance

The module is designed to meet HIPAA/GDPR compliance requirements:

- Encryption at rest
- Key rotation
- Access control
- Audit logging

## License

MIT Licensed. See LICENSE for full details. 