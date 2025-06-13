# EKS Troubleshooting Runbook

## Overview
This runbook provides comprehensive troubleshooting procedures for common EKS issues, including cluster, node group, and application-level problems.

## Prerequisites
- AWS CLI configured
- kubectl access
- CloudWatch access
- AWS CloudTrail access
- IAM permissions

## Cluster Issues

### 1. Cluster Creation Failures
```bash
# Check cluster status
aws eks describe-cluster --name pharma-infra-dev-cluster

# Check CloudWatch logs
aws logs get-log-events \
    --log-group-name /aws/eks/pharma-infra-dev-cluster/cluster \
    --log-stream-name $(aws logs describe-log-streams \
        --log-group-name /aws/eks/pharma-infra-dev-cluster/cluster \
        --order-by LastEventTime \
        --descending \
        --limit 1 \
        --query 'logStreams[0].logStreamName' \
        --output text)
```

### 2. API Server Issues
```bash
# Check API server health
kubectl cluster-info
kubectl get componentstatuses

# Check API server logs
kubectl logs -n kube-system -l component=kube-apiserver
```

### 3. Control Plane Issues
```bash
# Check control plane components
kubectl get pods -n kube-system

# Check control plane logs
kubectl logs -n kube-system -l component=kube-controller-manager
kubectl logs -n kube-system -l component=kube-scheduler
```

## Node Group Issues

### 1. Node Group Creation Failures
```bash
# Check node group status
aws eks describe-nodegroup \
    --cluster-name pharma-infra-dev-cluster \
    --nodegroup-name pharma-infra-dev-cluster-node-group

# Check node group events
aws eks list-nodegroup-events \
    --cluster-name pharma-infra-dev-cluster \
    --nodegroup-name pharma-infra-dev-cluster-node-group
```

### 2. Node Health Issues
```bash
# Check node status
kubectl get nodes
kubectl describe nodes

# Check node logs
kubectl logs -n kube-system -l component=kubelet
```

### 3. Scaling Issues
```bash
# Check autoscaling status
aws autoscaling describe-auto-scaling-groups \
    --query "AutoScalingGroups[?contains(Tags[?Key=='eks:nodegroup-name'].Value, 'pharma-infra-dev-cluster-node-group')]"

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/EKS \
    --metric-name node_cpu_utilization \
    --dimensions Name=ClusterName,Value=pharma-infra-dev-cluster
```

## Network Issues

### 1. VPC Connectivity
```bash
# Check VPC endpoints
aws ec2 describe-vpc-endpoints \
    --filters Name=vpc-id,Values=$(aws eks describe-cluster \
        --name pharma-infra-dev-cluster \
        --query 'cluster.resourcesVpcConfig.vpcId' \
        --output text)

# Check security groups
aws ec2 describe-security-groups \
    --filters Name=group-name,Values=pharma-infra-dev-cluster-*
```

### 2. Pod Network Issues
```bash
# Check CNI pods
kubectl get pods -n kube-system -l k8s-app=aws-node

# Check CNI logs
kubectl logs -n kube-system -l k8s-app=aws-node
```

### 3. Service Connectivity
```bash
# Check service endpoints
kubectl get endpoints
kubectl describe endpoints

# Check service logs
kubectl logs -n kube-system -l component=kube-proxy
```

## IAM and Security Issues

### 1. IAM Role Issues
```bash
# Check IAM roles
aws iam get-role --role-name pharma-infra-dev-cluster-role
aws iam get-role --role-name pharma-infra-dev-cluster-node-group-role

# Check role policies
aws iam list-role-policies --role-name pharma-infra-dev-cluster-role
aws iam list-attached-role-policies --role-name pharma-infra-dev-cluster-role
```

### 2. OIDC Provider Issues
```bash
# Check OIDC provider
aws iam list-open-id-connect-providers

# Check service account
kubectl get serviceaccount -A
kubectl describe serviceaccount -n kube-system aws-node
```

### 3. KMS Issues
```bash
# Check KMS key
aws kms describe-key --key-id $(aws eks describe-cluster \
    --name pharma-infra-dev-cluster \
    --query 'cluster.encryptionConfig[0].provider.keyArn' \
    --output text)

# Check KMS key policy
aws kms get-key-policy \
    --key-id $(aws eks describe-cluster \
        --name pharma-infra-dev-cluster \
        --query 'cluster.encryptionConfig[0].provider.keyArn' \
        --output text) \
    --policy-name default
```

## Application Issues

### 1. Pod Issues
```bash
# Check pod status
kubectl get pods -A
kubectl describe pods

# Check pod logs
kubectl logs -n <namespace> <pod-name>
```

### 2. Deployment Issues
```bash
# Check deployment status
kubectl get deployments -A
kubectl describe deployment -n <namespace> <deployment-name>

# Check deployment events
kubectl get events -n <namespace>
```

### 3. Service Issues
```bash
# Check service status
kubectl get services -A
kubectl describe service -n <namespace> <service-name>

# Check endpoint connectivity
kubectl get endpoints -n <namespace> <service-name>
```

## Monitoring and Logging

### 1. CloudWatch Metrics
```bash
# Check cluster metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/EKS \
    --metric-name cluster_failed_node_count \
    --dimensions Name=ClusterName,Value=pharma-infra-dev-cluster

# Check node metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/EKS \
    --metric-name node_cpu_utilization \
    --dimensions Name=ClusterName,Value=pharma-infra-dev-cluster
```

### 2. CloudTrail Events
```bash
# Check recent events
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=ResourceName,AttributeValue=pharma-infra-dev-cluster
```

### 3. Log Analysis
```bash
# Check cluster logs
aws logs get-log-events \
    --log-group-name /aws/eks/pharma-infra-dev-cluster/cluster

# Check node logs
aws logs get-log-events \
    --log-group-name /aws/eks/pharma-infra-dev-cluster/worker
```

## References
- [AWS EKS Troubleshooting Guide](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html)
- [Kubernetes Debugging Guide](https://kubernetes.io/docs/tasks/debug/)
- [AWS CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/) 