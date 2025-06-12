# AWS Config Module

This Terraform module creates an AWS Config configuration with S3 bucket for log storage and appropriate IAM roles and policies.

## Features

- AWS Config configuration recorder
- S3 bucket for log storage with:
  - Server-side encryption
  - Versioning
  - Lifecycle rules
  - Bucket policy
- IAM roles and policies
- HIPAA/GDPR compliant configuration

## Usage

```hcl
module "config" {
  source = "git::https://gitlab.com/repo/modules/security/config?ref=v1.0.0"

  project_name = "pharma-infra"
  environment  = "prod"

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
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| config_recorder_id | The name of the configuration recorder |
| config_recorder_arn | The Amazon Resource Name (ARN) of the configuration recorder |
| config_delivery_channel_id | The name of the delivery channel |
| config_s3_bucket_name | The name of the S3 bucket where AWS Config logs are stored |
| config_role_arn | The ARN of the IAM role used by AWS Config |

## Security

This module implements several security best practices:

- S3 bucket encryption
- IAM roles with least privilege
- Lifecycle rules for log retention
- Bucket policies for secure access

## Compliance

The module is designed to meet HIPAA/GDPR compliance requirements:

- Configuration monitoring (AWS Config)
- Data encryption (S3)
- Access control (IAM)
- Log retention (S3 lifecycle)

## License

MIT Licensed. See LICENSE for full details. 