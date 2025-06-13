# Terraform State Backup and Recovery Runbook

## Overview
This runbook provides procedures for backing up and recovering Terraform state files, ensuring infrastructure consistency and disaster recovery capabilities.

## Prerequisites
- AWS CLI configured
- S3 bucket access
- DynamoDB table access
- IAM permissions
- Terraform access

## State Backup Procedures

### 1. Manual State Backup
```bash
# Pull current state
terraform state pull > terraform.tfstate.backup

# Backup to S3
aws s3 cp terraform.tfstate.backup s3://pharma-infra-terraform-state/backups/$(date +%Y%m%d)/terraform.tfstate.backup

# Backup state file with timestamp
cp terraform.tfstate terraform.tfstate.$(date +%Y%m%d_%H%M%S)
```

### 2. Automated State Backup
```bash
# Create backup script
cat > backup-state.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="state-backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
terraform state pull > $BACKUP_DIR/terraform.tfstate.$DATE
aws s3 cp $BACKUP_DIR/terraform.tfstate.$DATE s3://pharma-infra-terraform-state/backups/$DATE/
EOF

# Make script executable
chmod +x backup-state.sh
```

### 3. State File Encryption
```bash
# Encrypt state file
aws kms encrypt \
    --key-id $(aws kms describe-key --key-id alias/pharma-infra-terraform-state --query 'KeyMetadata.KeyId' --output text) \
    --plaintext fileb://terraform.tfstate \
    --output text --query CiphertextBlob > terraform.tfstate.encrypted
```

## State Recovery Procedures

### 1. Manual State Recovery
```bash
# Download state from S3
aws s3 cp s3://pharma-infra-terraform-state/backups/20240101/terraform.tfstate.backup .

# Restore state
terraform state push terraform.tfstate.backup
```

### 2. State File Decryption
```bash
# Decrypt state file
aws kms decrypt \
    --ciphertext-blob fileb://terraform.tfstate.encrypted \
    --key-id $(aws kms describe-key --key-id alias/pharma-infra-terraform-state --query 'KeyMetadata.KeyId' --output text) \
    --output text --query Plaintext > terraform.tfstate.decrypted
```

### 3. State Verification
```bash
# Verify state integrity
terraform state list
terraform state show aws_eks_cluster.main
```

## State Management Best Practices

### 1. State File Organization
- Use separate state files for different environments
- Implement state file versioning
- Maintain state file backups
- Use remote state storage

### 2. Access Control
- Implement least privilege access
- Use IAM roles for state access
- Enable state file encryption
- Implement state file locking

### 3. Monitoring and Alerting
- Monitor state file changes
- Alert on state file modifications
- Track state file backups
- Monitor state file size

## Disaster Recovery

### 1. State File Corruption
```bash
# Identify corruption
terraform state list

# Restore from backup
aws s3 cp s3://pharma-infra-terraform-state/backups/latest/terraform.tfstate .
terraform state push terraform.tfstate
```

### 2. State File Loss
```bash
# Recreate state file
terraform import aws_eks_cluster.main pharma-infra-dev-cluster
terraform import aws_eks_node_group.main pharma-infra-dev-cluster/pharma-infra-dev-cluster-node-group
```

### 3. State File Conflict
```bash
# Resolve conflicts
terraform state pull > current.tfstate
terraform state push -force current.tfstate
```

## Regular Maintenance

### 1. Daily Tasks
- Verify state file integrity
- Check state file backups
- Monitor state file changes
- Review state file access

### 2. Weekly Tasks
- Clean up old backups
- Verify backup integrity
- Update backup procedures
- Review access logs

### 3. Monthly Tasks
- Audit state file access
- Review backup retention
- Update recovery procedures
- Test recovery process

## Security Considerations

### 1. Access Control
- Implement state file locking
- Use IAM roles for access
- Enable state file encryption
- Monitor state file access

### 2. Data Protection
- Encrypt state files
- Use KMS for encryption
- Implement backup encryption
- Secure backup storage

### 3. Audit and Compliance
- Log state file access
- Track state file changes
- Monitor backup operations
- Review access patterns

## References
- [Terraform State Management](https://www.terraform.io/language/state)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS KMS Documentation](https://docs.aws.amazon.com/kms/) 