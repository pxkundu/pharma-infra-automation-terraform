# Development Environment

This directory contains the Terraform configuration for the development environment of the Pharma Infrastructure project.

## Overview

The development environment includes:

- VPC with public and private subnets
- EKS cluster with managed node groups
- KMS key for encryption
- Security services:
  - CloudTrail for audit logging
  - AWS Config for configuration management
  - GuardDuty for threat detection

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- S3 bucket for Terraform state
- DynamoDB table for state locking

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the planned changes:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. To destroy the infrastructure:
   ```bash
   terraform destroy
   ```

## Configuration

The environment is configured through the following files:

- `main.tf`: Main Terraform configuration
- `variables.tf`: Variable definitions
- `outputs.tf`: Output definitions
- `terraform.tfvars`: Environment-specific values

## Security

This environment implements several security measures:

- Private subnets for sensitive resources
- KMS encryption for data at rest
- CloudTrail for audit logging
- AWS Config for configuration monitoring
- GuardDuty for threat detection
- IAM roles with least privilege

## Compliance

The environment is designed to meet HIPAA/GDPR compliance requirements:

- Network isolation
- Data encryption
- Audit logging
- Access control
- Configuration management
- Threat detection

## Maintenance

Regular maintenance tasks:

1. Update Kubernetes version
2. Rotate KMS keys
3. Review security group rules
4. Monitor CloudTrail logs
5. Check AWS Config compliance
6. Review GuardDuty findings

## Troubleshooting

Common issues and solutions:

1. EKS cluster access issues:
   - Check IAM roles and policies
   - Verify security group rules
   - Ensure kubectl is configured correctly

2. Network connectivity:
   - Verify VPC configuration
   - Check NAT Gateway status
   - Review route tables

3. Security service issues:
   - Check CloudTrail S3 bucket permissions
   - Verify AWS Config recorder status
   - Review GuardDuty detector settings

## License

MIT Licensed. See LICENSE for full details. 