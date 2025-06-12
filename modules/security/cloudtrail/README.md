# CloudTrail Module

This Terraform module creates a CloudTrail configuration with S3 bucket for log storage and CloudWatch Logs integration.

## Features

- Multi-region CloudTrail trail
- S3 bucket for log storage with:
  - Server-side encryption
  - Versioning
  - Lifecycle rules
  - Bucket policy
- CloudWatch Logs integration
- KMS encryption
- IAM roles and policies
- HIPAA/GDPR compliant configuration

## Usage

```hcl
module "cloudtrail" {
  source = "git::https://gitlab.com/repo/modules/security/cloudtrail?ref=v1.0.0"

  project_name = "pharma-infra"
  environment  = "prod"
  kms_key_arn  = module.kms.key_arn

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
| kms_key_arn | ARN of the KMS key for CloudTrail encryption | `string` | n/a | yes |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudtrail_id | The name of the trail |
| cloudtrail_arn | The Amazon Resource Name (ARN) of the trail |
| cloudtrail_home_region | The region in which the trail was created |
| cloudtrail_s3_bucket_name | The name of the S3 bucket where CloudTrail logs are stored |
| cloudtrail_cloudwatch_log_group_arn | The ARN of the CloudWatch Log Group where CloudTrail logs are sent |
| cloudtrail_cloudwatch_role_arn | The ARN of the IAM role used by CloudTrail to write to CloudWatch Logs |

## Security

This module implements several security best practices:

- Multi-region trail for comprehensive logging
- S3 bucket encryption
- KMS encryption for logs
- IAM roles with least privilege
- CloudWatch Logs for centralized logging
- Lifecycle rules for log retention

## Compliance

The module is designed to meet HIPAA/GDPR compliance requirements:

- Audit logging (CloudTrail)
- Data encryption (S3, KMS)
- Access control (IAM)
- Log retention (S3 lifecycle)
- Centralized logging (CloudWatch)

## License

MIT Licensed. See LICENSE for full details. 