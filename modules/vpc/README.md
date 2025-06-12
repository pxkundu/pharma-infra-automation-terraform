# VPC Module

This Terraform module creates a VPC with public and private subnets across multiple Availability Zones, along with NAT Gateways, Internet Gateway, and VPC Flow Logs.

## Features

- VPC with public and private subnets
- NAT Gateways with Elastic IPs
- Internet Gateway
- Route tables for public and private subnets
- VPC Flow Logs with CloudWatch Logs
- IAM roles and policies for VPC Flow Logs
- Support for multiple Availability Zones
- Configurable NAT Gateway deployment (single or multiple)

## Usage

```hcl
module "vpc" {
  source = "git::https://gitlab.com/repo/modules/vpc?ref=v1.0.0"

  project_name = "pharma-infra"
  environment  = "prod"
  vpc_cidr     = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets    = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

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
| vpc_cidr | CIDR block for VPC | `string` | n/a | yes |
| availability_zones | List of availability zones | `list(string)` | n/a | yes |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | n/a | yes |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | n/a | yes |
| enable_nat_gateway | Whether to enable NAT Gateway | `bool` | `true` | no |
| single_nat_gateway | Whether to use a single NAT Gateway for all private subnets | `bool` | `false` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| private_subnet_ids | List of IDs of private subnets |
| public_subnet_ids | List of IDs of public subnets |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_public_ips | List of allocation IDs of Elastic IPs created for NAT Gateway |
| private_route_table_ids | List of IDs of private route tables |
| public_route_table_ids | List of IDs of public route tables |
| default_security_group_id | The ID of the security group created by default on VPC creation |
| vpc_flow_log_id | The ID of the Flow Log resource |
| vpc_flow_log_cloudwatch_log_group_arn | The ARN of the CloudWatch Log Group where VPC Flow Logs are sent |

## Security

This module implements several security best practices:

- Private subnets for sensitive resources
- NAT Gateways for outbound internet access
- VPC Flow Logs for network traffic monitoring
- IAM roles with least privilege
- CloudWatch Logs for audit trail

## Compliance

The module is designed to meet HIPAA/GDPR compliance requirements:

- Network isolation (private subnets)
- Audit logging (VPC Flow Logs)
- Access control (security groups)
- Data protection (encryption)

## License

MIT Licensed. See LICENSE for full details. 