# Operational Runbooks Documentation

## Overview
This document provides operational runbooks for managing the Terraform-based EKS infrastructure automation project for a Fortune 100 medical/pharmaceutical company. These runbooks cover common operational tasks, troubleshooting, and maintenance procedures for the EKS-centric microservices infrastructure, ensuring reliability, security, and compliance.

## Runbooks
### 1. Deploying a New EKS Environment
**Purpose**: Provision a new EKS environment (e.g., dev, staging, prod).
**Steps**:
1. Navigate to the environment directory:
   ```bash
   cd environments/<env>
   ```
2. Update `terraform.tfvars` with environment-specific values (e.g., node count, VPC CIDR).
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Validate and plan:
   ```bash
   terraform validate
   terraform plan -out=tfplan
   ```
5. Apply configuration:
   ```bash
   terraform apply tfplan
   ```
6. Verify EKS cluster:
   - Check cluster status in AWS Console or with `kubectl get nodes`.
   - Validate microservices deployment with `helm ls`.
**Dependencies**: S3/DynamoDB backend, VPC module, IAM module.
**Validation**: Terratest scripts in `tests/terratest/eks_test.go`.

### 2. Upgrading an EKS Module
**Purpose**: Upgrade an EKS module to a new version (e.g., `v1.0.0` to `v1.1.0`).
**Steps**:
1. Update module version in `environments/<env>/main.tf`:
   ```hcl
   module "eks" {
     source = "git::https://gitlab.com/repo/modules/eks?ref=v1.1.0"
   }
   ```
2. Test in dev environment:
   ```bash
   cd environments/dev
   terraform init -upgrade
   terraform plan -out=tfplan
   terraform apply tfplan
   ```
3. Run Terratest to validate (`tests/terratest/eks_test.go`).
4. Promote to staging/prod with CI/CD pipeline approval.
5. Monitor CloudWatch/Prometheus for cluster health post-upgrade.
**Dependencies**: Updated module in GitLab.
**Risks**: Version incompatibility; mitigated by dev testing.

### 3. Detecting and Resolving Configuration Drift
**Purpose**: Identify and remediate EKS resources deviating from Terraform code.
**Steps**:
1. Run drift detection script:
   ```bash
   ./scripts/drift-detection.sh environments/<env>
   ```
2. Review `terraform plan` output for discrepancies.
3. Apply changes if safe:
   ```bash
   terraform apply -auto-approve
   ```
4. For manual changes, use `terraform taint` to mark resources:
   ```bash
   terraform taint module.eks.aws_eks_cluster.cluster
   ```
5. Re-apply to reconcile:
   ```bash
   terraform apply
   ```
6. Log drift incidents in JIRA.
**Tools**: `scripts/drift-detection.sh`, CloudWatch for monitoring.
**Validation**: Post-apply `terraform plan` shows no changes.

### 4. Troubleshooting EKS Cluster Issues
**Purpose**: Diagnose and resolve common EKS cluster problems.
**Steps**:
1. Check EKS control plane status:
   ```bash
   aws eks describe-cluster --name <cluster-name> --region us-east-1
   ```
2. Verify node group health:
   ```bash
   kubectl get nodes
   ```
3. Inspect pod logs for microservices issues:
   ```bash
   kubectl logs <pod-name> -n <namespace>
   ```
4. Review CloudWatch logs for EKS control plane errors.
5. Check Prometheus/Grafana for resource bottlenecks.
6. Escalate to AWS Support if unresolved.
**Tools**: `kubectl`, CloudWatch, Prometheus/Grafana.
**Runbook**: `docs/runbooks/troubleshooting-eks.md`.

### 5. Backing Up Terraform State
**Purpose**: Ensure Terraform state is backed up for disaster recovery.
**Steps**:
1. Run state backup script:
   ```bash
   ./scripts/state-backup.sh
   ```
2. Verify backup in S3:
   - Check `s3://<backend-bucket>/backups/` for timestamped state files.
3. Test state restoration:
   ```bash
   aws s3 cp s3://<backend-bucket>/backups/<timestamp>/terraform.tfstate .
   terraform init -force-copy
   ```
4. Schedule daily backups in CI/CD pipeline.
**Tools**: `scripts/state-backup.sh`, S3 versioning.
**Validation**: Restored state matches current infrastructure.

## Location
- Runbooks are stored in `docs/runbooks/`.
- Refer to:
  - `docs/runbooks/deploy-eks-environment.md`
  - `docs/runbooks/upgrade-eks-module.md`
  - `docs/runbooks/drift-detection.md`
  - `docs/runbooks/troubleshooting-eks.md`
  - `docs/runbooks/state-backup.md`