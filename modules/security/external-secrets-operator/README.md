# External Secrets Operator Module

This Terraform module deploys the External Secrets Operator (ESO) in an EKS cluster, enabling secure integration with AWS Secrets Manager for Kubernetes secrets management.

## Features

- Deploys External Secrets Operator via Helm
- Configures IAM roles and policies for AWS Secrets Manager access
- Sets up ClusterSecretStore for AWS integration
- Implements secure service account configuration
- Provides example ExternalSecret resource
- Supports multiple environments (dev, staging, prod)

## Usage

```hcl
module "external_secrets" {
  source = "../../modules/security/external-secrets-operator"

  project_name = "pharma-infra"
  environment  = "prod"
  cluster_name = module.eks.cluster_name

  cluster_oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  cluster_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  
  aws_region    = "us-east-1"
  aws_account_id = "123456789012"
  kms_key_arn   = module.kms.key_arn

  chart_version = "0.9.5"
  
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
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| cluster_oidc_provider_arn | ARN of the EKS cluster OIDC provider | `string` | n/a | yes |
| cluster_oidc_issuer_url | URL of the EKS cluster OIDC issuer | `string` | n/a | yes |
| aws_region | AWS region | `string` | n/a | yes |
| aws_account_id | AWS account ID | `string` | n/a | yes |
| kms_key_arn | ARN of the KMS key used for encryption | `string` | n/a | yes |
| chart_version | Version of the External Secrets Operator Helm chart | `string` | `"0.9.5"` | no |
| create_example_secret | Whether to create an example ExternalSecret resource | `bool` | `false` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| external_secrets_role_arn | ARN of the IAM role for External Secrets Operator |
| external_secrets_role_name | Name of the IAM role for External Secrets Operator |
| external_secrets_namespace | Namespace where External Secrets Operator is installed |
| external_secrets_release_name | Name of the Helm release for External Secrets Operator |
| external_secrets_version | Version of External Secrets Operator installed |

## Security

This module implements several security best practices:

- IAM roles with least privilege
- KMS encryption for secrets
- Secure service account configuration
- Non-root container execution
- Regular secret rotation support

## Compliance

The module is designed to meet HIPAA/GDPR compliance requirements:

- Encrypted secrets storage
- Access control and audit logging
- Secure secret management
- Regular key rotation

## Example ExternalSecret Usage

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: my-app
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: ClusterSecretStore
  target:
    name: database-credentials
  data:
    - secretKey: username
      remoteRef:
        key: prod/database/credentials
        property: username
    - secretKey: password
      remoteRef:
        key: prod/database/credentials
        property: password
```

## License

MIT Licensed. See LICENSE for full details. 