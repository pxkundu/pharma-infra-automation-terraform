# EKS Infrastructure Drift Detection Runbook

## Overview
This runbook provides procedures for detecting and managing infrastructure drift in the EKS environment, including Terraform state drift and manual changes.

## Prerequisites
- Terraform access
- AWS CLI configured
- kubectl access
- CloudWatch access
- AWS Config enabled

## Drift Detection Methods

### 1. Terraform Drift Detection
```bash
# Check for drift
terraform plan

# Detailed drift check
terraform plan -detailed-exitcode
```

### 2. AWS Config Rules
```bash
# List active rules
aws configservice describe-config-rules

# Check compliance
aws configservice get-compliance-details-by-config-rule \
    --config-rule-name eks-cluster-compliance
```

### 3. CloudWatch Alarms
```bash
# List drift detection alarms
aws cloudwatch describe-alarms \
    --alarm-name-prefix eks-drift
```

## Common Drift Scenarios

### 1. Node Group Drift
- Instance type changes
- AMI updates
- Scaling configuration changes
- Security group modifications

### 2. Cluster Configuration Drift
- API server endpoint changes
- Logging configuration
- Encryption settings
- Network policy changes

### 3. IAM Role Drift
- Policy modifications
- Trust relationship changes
- Service account updates
- OIDC provider changes

## Drift Resolution Procedures

### 1. Automatic Resolution
```bash
# Apply Terraform configuration
terraform apply -auto-approve

# Refresh state
terraform refresh
```

### 2. Manual Resolution
1. Document the drift
2. Assess impact
3. Plan resolution
4. Execute changes
5. Verify resolution

### 3. State Reconciliation
```bash
# Import manually created resources
terraform import module.eks.aws_eks_cluster.main cluster-name

# Update state
terraform state pull > current.tfstate
```

## Monitoring and Alerting

### 1. CloudWatch Alarms
- State drift detection
- Configuration changes
- Resource modifications

### 2. AWS Config Rules
- EKS cluster compliance
- Node group compliance
- IAM role compliance

### 3. Custom Metrics
- Drift frequency
- Resolution time
- Impact assessment

## Prevention Strategies

### 1. Access Control
- IAM policy restrictions
- Resource tagging
- AWS Organizations SCPs

### 2. Automation
- Infrastructure as Code
- CI/CD pipelines
- Automated testing

### 3. Monitoring
- Real-time drift detection
- Change tracking
- Audit logging

## Documentation

### 1. Drift Log
- Date and time
- Resource affected
- Change type
- Resolution method

### 2. Impact Assessment
- Service impact
- User impact
- Cost impact

### 3. Resolution Steps
- Required actions
- Verification steps
- Rollback procedures

## Regular Maintenance

### 1. Daily Checks
- Terraform plan
- CloudWatch alarms
- AWS Config compliance

### 2. Weekly Reviews
- Drift patterns
- Resolution effectiveness
- Prevention strategies

### 3. Monthly Audits
- Access review
- Configuration review
- Documentation update

## Emergency Procedures

### 1. Critical Drift
- Immediate notification
- Impact assessment
- Resolution planning
- Execution and verification

### 2. Service Impact
- Service degradation
- User impact
- Communication plan

### 3. Rollback Plan
- State restoration
- Configuration rollback
- Service recovery

## References
- [AWS Config Documentation](https://docs.aws.amazon.com/config/)
- [Terraform State Management](https://www.terraform.io/language/state)
- [AWS EKS Best Practices](https://docs.aws.amazon.com/eks/latest/userguide/best-practices.html) 