# EKS Module Upgrade Runbook

## Overview
This runbook provides guidelines and procedures for upgrading the EKS module, including cluster version updates, node group updates, and infrastructure changes.

## Prerequisites
- Access to AWS environment
- Terraform state access
- kubectl configured
- Backup of current state
- Maintenance window scheduled

## Pre-Upgrade Tasks

### 1. Backup Current State
```bash
# Backup Terraform state
terraform state pull > terraform.tfstate.backup

# Backup kubeconfig
cp ~/.kube/config ~/.kube/config.backup
```

### 2. Document Current Version
```bash
# Get current EKS version
aws eks describe-cluster --name pharma-infra-dev-cluster --query "cluster.version"

# Get current node group version
aws eks describe-nodegroup \
    --cluster-name pharma-infra-dev-cluster \
    --nodegroup-name pharma-infra-dev-cluster-node-group \
    --query "nodegroup.version"
```

### 3. Check Compatibility
- Review AWS EKS version compatibility matrix
- Verify node group AMI compatibility
- Check add-on compatibility (External Secrets Operator)

## Upgrade Procedures

### 1. Minor Version Upgrade
```bash
# Update kubernetes_version in terraform.tfvars
terraform plan -out=tfplan
terraform apply tfplan
```

### 2. Major Version Upgrade
1. Create new node group
2. Drain old node group
3. Remove old node group
4. Update control plane

### 3. Node Group Updates
```bash
# Update node group configuration
terraform plan -target=module.eks.aws_eks_node_group.main -out=tfplan
terraform apply tfplan
```

## Post-Upgrade Verification

### 1. Cluster Health Check
```bash
# Check cluster status
aws eks describe-cluster --name pharma-infra-dev-cluster

# Verify node health
kubectl get nodes
kubectl describe nodes
```

### 2. Application Verification
```bash
# Check all pods are running
kubectl get pods -A

# Verify External Secrets Operator
kubectl get pods -n external-secrets
```

### 3. Log Verification
```bash
# Check CloudWatch logs
aws logs describe-log-streams \
    --log-group-name /aws/eks/pharma-infra-dev-cluster/cluster
```

## Rollback Procedures

### 1. Quick Rollback
```bash
# Restore previous state
terraform state push terraform.tfstate.backup
terraform apply
```

### 2. Node Group Rollback
```bash
# Scale up old node group
# Scale down new node group
# Remove new node group
```

## Common Issues

### 1. Version Mismatch
- Control plane and node group version mismatch
- Add-on version incompatibility
- AMI version issues

### 2. Node Group Issues
- Node group creation failures
- Node group scaling issues
- AMI compatibility problems

### 3. Application Issues
- Pod scheduling problems
- Network connectivity issues
- Storage class compatibility

## Monitoring During Upgrade

### 1. CloudWatch Metrics
- Cluster API server errors
- Node group scaling events
- Pod scheduling metrics

### 2. Application Metrics
- Pod health checks
- Application response times
- Error rates

## Security Considerations

### 1. IAM Updates
- Review IAM role permissions
- Update OIDC provider if needed
- Verify service account permissions

### 2. Network Security
- Verify security group rules
- Check VPC endpoint configurations
- Validate network policies

## Maintenance Tasks

### 1. Post-Upgrade Cleanup
- Remove old node groups
- Clean up unused security groups
- Update documentation

### 2. Documentation Updates
- Update runbooks
- Document new configurations
- Update troubleshooting guides

## References
- [AWS EKS Upgrade Guide](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
- [Terraform EKS Module Documentation](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws)
- [Kubernetes Version Skew Policy](https://kubernetes.io/docs/setup/release/version-skew-policy/) 