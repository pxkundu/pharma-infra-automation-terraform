# EKS Environment Deployment Runbook

## Overview
This runbook provides step-by-step instructions for deploying a new EKS environment using our Terraform infrastructure code.

## Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform v1.0.0 or later
- kubectl installed
- Access to AWS Secrets Manager
- Required IAM permissions

## Environment Variables
```bash
export AWS_REGION=us-east-1
export TF_VAR_project_name=pharma-infra
export TF_VAR_environment=dev
```

## Deployment Steps

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Validate Configuration
```bash
terraform validate
```

### 3. Plan Deployment
```bash
terraform plan -out=tfplan
```

### 4. Apply Configuration
```bash
terraform apply tfplan
```

### 5. Configure kubectl
```bash
aws eks update-kubeconfig --name pharma-infra-dev-cluster --region us-east-1
```

### 6. Verify Deployment
```bash
kubectl get nodes
kubectl get pods -A
```

## Post-Deployment Tasks

### 1. Verify External Secrets Operator
```bash
kubectl get pods -n external-secrets
kubectl get clustersecretstore
```

### 2. Check Node Group Status
```bash
aws eks describe-nodegroup \
    --cluster-name pharma-infra-dev-cluster \
    --nodegroup-name pharma-infra-dev-cluster-node-group
```

### 3. Verify Security Groups
```bash
aws ec2 describe-security-groups \
    --filters Name=group-name,Values=pharma-infra-dev-cluster-*
```

## Common Issues and Solutions

### 1. Node Group Creation Fails
- Check IAM role permissions
- Verify subnet configurations
- Ensure AMI ID is valid for the region

### 2. External Secrets Operator Issues
- Verify OIDC provider configuration
- Check IAM role permissions
- Validate KMS key access

### 3. Network Connectivity Issues
- Verify VPC endpoints
- Check security group rules
- Validate subnet configurations

## Rollback Procedure

### 1. Destroy Specific Resources
```bash
terraform destroy -target=module.eks
```

### 2. Full Environment Rollback
```bash
terraform destroy
```

## Monitoring and Alerts

### 1. CloudWatch Alarms
- Node group scaling events
- Cluster API server errors
- Node health status

### 2. Log Groups to Monitor
- /aws/eks/pharma-infra-dev-cluster/cluster
- /aws/eks/pharma-infra-dev-cluster/worker

## Security Considerations

### 1. IAM Roles
- Ensure least privilege access
- Regular permission audits
- Rotate access keys

### 2. Network Security
- Private subnets for nodes
- Restricted API server access
- VPC endpoints for AWS services

### 3. Encryption
- KMS key rotation
- EBS volume encryption
- Secrets encryption

## Maintenance Tasks

### 1. Regular Updates
- EKS version updates
- Node group AMI updates
- Security group rule reviews

### 2. Backup Procedures
- State file backups
- KMS key backups
- IAM role backups

## References
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)
- [External Secrets Operator Documentation](https://external-secrets.io/) 