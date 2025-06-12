# HIPAA/GDPR Compliance Controls Documentation

## Overview
This document outlines the HIPAA and GDPR compliance controls implemented in the Terraform-based EKS infrastructure automation project for a Fortune 100 medical/pharmaceutical company. It ensures the infrastructure meets regulatory requirements for handling Protected Health Information (PHI) and personal data in microservices workloads (e.g., clinical trial data, EMR).

## Compliance Controls
### 1. HIPAA Controls
| **Control** | **Description** | **Terraform Implementation** |
|-------------|-----------------|------------------------------|
| **Data Encryption** | Encrypt PHI at rest and in transit. | - `aws_kms_key` for EBS, S3, and Secrets Manager encryption.<br>- `aws_eks_cluster` with encrypted EBS volumes for node groups.<br>- TLS enabled for microservices ingress via AWS Load Balancer Controller. |
| **Access Control** | Restrict access to PHI with least privilege. | - `aws_iam_role` with IRSA for pod-specific permissions.<br>- Pod security policies via Kubernetes provider to limit privileged containers.<br>- MFA enforced via global IAM policies. |
| **Audit Logging** | Log all access and modifications to PHI. | - `aws_cloudtrail` for EKS API call auditing, stored in S3.<br>- `aws_eks_cluster` with control plane logging (API, audit, authenticator).<br>- Logs centralized in Security account S3 bucket. |
| **Data Integrity** | Ensure PHI is not altered unauthorizedly. | - S3 versioning enabled in `aws_s3_bucket_versioning`.<br>- Immutable Helm chart deployments for microservices. |
| **Availability** | Ensure high availability of PHI systems. | - Multi-AZ EKS node groups via `aws_eks_node_group`.<br>- Auto-scaling configured in `scaling_config` for reliability. |

### 2. GDPR Controls
| **Control** | **Description** | **Terraform Implementation** |
|-------------|-----------------|------------------------------|
| **Data Minimization** | Collect and process only necessary data. | - Pod-level data isolation using network policies via Kubernetes provider.<br>- Microservices configured to process minimal PHI subsets. |
| **Data Protection** | Protect personal data with encryption and access controls. | - `aws_kms_key` for encrypting EBS and S3.<br>- `aws_secretsmanager_secret` for sensitive data (e.g., database credentials).<br>- Private EKS endpoints in `aws_eks_cluster`. |
| **Auditability** | Maintain records of data processing activities. | - `aws_cloudtrail` logs EKS and AWS API calls.<br>- `aws_config_rule` monitors compliance (e.g., encrypted EBS).<br>- Logs queryable with Athena in Security account. |
| **Data Subject Rights** | Enable data deletion and portability. | - S3 lifecycle policies in `aws_s3_bucket_lifecycle_configuration` for data retention.<br>- Microservices designed with APIs for data export/deletion, deployed via Helm. |
| **Breach Notification** | Detect and report data breaches. | - `aws_guardduty_detector` for EKS threat detection.<br>- CloudWatch alarms integrated with Slack for breach alerts. |

## Terraform Modules Supporting Compliance
- **CloudTrail Module**: Configures centralized API logging to S3 (`modules/security/cloudtrail`).
- **AWS Config Module**: Monitors compliance rules (e.g., encrypted EBS) (`modules/security/config`).
- **GuardDuty Module**: Enables threat detection (`modules/security/guardduty`).
- **KMS Module**: Manages encryption keys (`modules/kms`).
- **IAM Module**: Enforces least privilege with IRSA (`modules/iam`).

## Validation
- **CI/CD Pipeline**: Checkov scans Terraform code for compliance misconfigurations.
- **Audits**: Regular compliance audits using AWS Config and CloudTrail logs.
- **Testing**: Terratest validates encryption and logging configurations (`tests/terratest`).

## Location
- Compliance documentation is stored in `docs/compliance/`.
- Refer to `docs/compliance/hipaa-controls.md` and `gdpr-controls.md` for detailed control mappings.