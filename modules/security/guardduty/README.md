# AWS GuardDuty Module

This Terraform module creates an AWS GuardDuty configuration with threat detection, filtering, and notification capabilities. It includes integration with CloudWatch Events and SNS for alerting.

## Features

- GuardDuty detector with multiple data sources:
  - S3 logs monitoring
  - Kubernetes audit logs
  - Malware protection for EC2 instances
- High severity findings filter
- Threat intelligence set integration
- Trusted IPs set
- CloudWatch Events integration for findings
- SNS notification setup
- IAM roles and policies for secure access

## Usage

```hcl
module "guardduty" {
  source = "./modules/security/guardduty"

  project_name = "my-project"
  environment  = "prod"

  threat_intel_bucket = "my-threat-intel-bucket"
  threat_intel_key    = "threat-intel/known-bad-ips.txt"
  
  trusted_ips_bucket = "my-trusted-ips-bucket"
  trusted_ips_key    = "trusted-ips/allowed-ips.txt"
  
  sns_topic_arn = "arn:aws:sns:region:account-id:my-topic"

  tags = {
    Environment = "prod"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment (e.g., dev, staging, prod) | `string` | n/a | yes |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| threat_intel_bucket | S3 bucket containing the threat intelligence set | `string` | n/a | yes |
| threat_intel_key | S3 key for the threat intelligence set | `string` | n/a | yes |
| trusted_ips_bucket | S3 bucket containing the trusted IPs set | `string` | n/a | yes |
| trusted_ips_key | S3 key for the trusted IPs set | `string` | n/a | yes |
| sns_topic_arn | ARN of the SNS topic for GuardDuty findings | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| detector_id | The ID of the GuardDuty detector |
| detector_arn | The ARN of the GuardDuty detector |
| filter_id | The ID of the GuardDuty filter |
| threat_intel_set_id | The ID of the GuardDuty threat intel set |
| ipset_id | The ID of the GuardDuty IP set |
| cloudwatch_event_rule_arn | The ARN of the CloudWatch Event Rule for GuardDuty findings |
| guardduty_sns_role_arn | The ARN of the IAM role for GuardDuty to publish to SNS |

## Security

This module implements several security best practices:

- Enables all relevant GuardDuty data sources
- Configures high severity findings filter
- Integrates with threat intelligence feeds
- Maintains a trusted IPs list
- Uses IAM roles with least privilege
- Implements secure SNS notification delivery

## Compliance

This module helps meet various compliance requirements:

### HIPAA
- Enables continuous monitoring of AWS resources
- Provides threat detection and alerting
- Maintains audit logs of security findings

### GDPR
- Monitors for unauthorized access attempts
- Detects potential data breaches
- Provides audit trail of security events

## License

MIT Licensed. See LICENSE for full details. 