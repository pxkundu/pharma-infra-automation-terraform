# Kubernetes Based Microservices Infrastructure Automation with Terraform

## Overview
This project automates the provisioning and management of a secure, scalable, HIPAA/GDPR-compliant Amazon Elastic Kubernetes Service (EKS) infrastructure using Terraform for a Fortune 100 medical and pharmaceutical company. It supports containerized microservices workloads such as clinical trial data processing, electronic medical records (EMR), and drug discovery pipelines. The infrastructure adheres to AWS Well-Architected Framework principles, Terraform lifecycle management best practices, and enterprise-grade standards for security, reliability, and compliance.

### Key Features
- **EKS-Centric Infrastructure**: Deploys EKS clusters with managed node groups, Fargate profiles, and Helm-based microservices deployments.
- **Security**: Implements least privilege IAM roles, KMS encryption, and pod security policies.
- **Networking**: Provisions multi-AZ VPC, Transit Gateway, and VPC endpoints for private connectivity.
- **Compliance**: Ensures HIPAA/GDPR compliance with CloudTrail auditing, AWS Config rules, and GuardDuty.
- **Automation**: Uses CI/CD pipelines (GitLab CI/AWS CodePipeline) with Terratest and Checkov for validation.
- **Dependency Management**: Modular Terraform structure with versioned modules and clear dependency chains.

## Project Structure
The repository is organized to promote modularity, reusability, and environment isolation.

```
.
├── .github/workflows/           # GitHub Actions for CI/CD pipelines
├── environments/                # Environment-specific configurations (dev, staging, prod)
│   ├── dev/                    # Development environment
│   ├── staging/                # Staging environment
│   └── prod/                   # Production environment
├── modules/                    # Reusable Terraform modules
│   ├── eks/                    # EKS cluster, node groups, Fargate, Helm deployments
│   ├── vpc/                    # Multi-AZ VPC with private/public subnets
│   ├── iam/                    # IAM roles and policies for EKS and microservices
│   ├── kms/                    # KMS keys for encryption
│   ├── security/               # CloudTrail, AWS Config, GuardDuty
│   └── networking/             # Transit Gateway, VPC endpoints
├── global/                     # Global resources (S3 backend, shared IAM)
│   ├── backend/                # S3/DynamoDB for Terraform state
│   └── iam/                    # Global IAM policies
├── tests/                      # Testing configurations
│   ├── terratest/             # Terratest scripts for EKS and VPC validation
│   └── checkov/               # Checkov security scans
├── docs/                       # Documentation
│   ├── architecture/          # Architecture diagrams
│   ├── compliance/            # HIPAA/GDPR compliance docs
│   └── runbooks/             # Operational runbooks
├── scripts/                    # Utility scripts (drift detection, state backup)
├── .gitignore                  # Git ignore patterns
├── .pre-commit-config.yaml     # Pre-commit hooks for code quality
├── README.md                   # Project documentation
├── versions.tf                 # Provider version constraints
├── variables.tf                # Global variables
└── outputs.tf                  # Global outputs
```

## Prerequisites
- **Terraform**: v1.5+ installed locally or in CI/CD environment.
- **AWS CLI**: Configured with credentials for the target AWS account.
- **GitLab**: Repository access for module versioning and CI/CD pipelines.
- **Tools**:
  - Helm CLI for microservices deployments.
  - Go for Terratest scripts.
  - Checkov for Terraform security scanning.
  - AWS credentials with permissions for EKS, VPC, IAM, KMS, and compliance services.

## Setup Instructions
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/pxkundu/pharma-infra-automation-terraform.git

   ```

2. **Configure Terraform Backend**:
   - Update `global/backend/main.tf` with your S3 bucket and DynamoDB table for state management.
   - Run `terraform init` in the `global/backend` directory to initialize the backend.

3. **Set Environment Variables**:
   - Configure AWS credentials:
     ```bash
     export AWS_ACCESS_KEY_ID=<your-access-key>
     export AWS_SECRET_ACCESS_KEY=<your-secret-key>
     export AWS_REGION=us-east-1
     ```

4. **Initialize Terraform**:
   - Navigate to the desired environment (e.g., `environments/dev`).
   - Run:
     ```bash
     terraform init
     ```

5. **Customize Variables**:
   - Update `environments/<env>/terraform.tfvars` with environment-specific values (e.g., EKS node count, VPC CIDR).

6. **Validate and Plan**:
   - Run:
     ```bash
     terraform validate
     terraform plan -out=tfplan
     ```

7. **Apply Configuration**:
   - Deploy the infrastructure:
     ```bash
     terraform apply tfplan
     ```

## Usage Guidelines
### EKS Module
- **Purpose**: Provisions EKS clusters with private endpoints, control plane logging, and OIDC provider.
- **Key Resources**:
  - `aws_eks_cluster`: Configures EKS control plane.
  - `aws_eks_node_group`: Managed node groups with auto-scaling and encrypted EBS.
  - `aws_eks_fargate_profile`: Serverless compute for stateless microservices.
  - `helm_release`: Deploys AWS Load Balancer Controller, Cluster Autoscaler, and microservices.
- **Dependencies**: Requires VPC and IAM modules.

### Security Modules
- **IAM**: Creates EKS cluster roles, node group roles, and IRSA for pod permissions.
- **KMS**: Manages encryption keys for EBS, S3, and Secrets Manager.
- **Security Components**:
  - `cloudtrail`: Logs EKS API calls to S3.
  - `config`: Monitors compliance (e.g., encrypted EBS).
  - `guardduty`: Detects threats in EKS workloads.
- **Dependencies**: IAM depends on KMS; CloudTrail depends on S3.

### Secrets Management
The infrastructure implements a comprehensive secrets management strategy using AWS KMS and EKS native features:

#### KMS (Key Management Service)
- **Key Creation and Management**:
  - Environment-specific KMS keys (`dev`, `staging`, `prod`)
  - Automatic key rotation enabled
  - Proper IAM policies for key usage
  - Service-specific permissions for EKS, CloudTrail, and CloudWatch

- **Key Usage**:
  - EKS cluster secrets encryption
  - EBS volume encryption for EKS nodes
  - CloudTrail log encryption
  - S3 bucket encryption
  - Terraform state encryption

#### External Secrets Operator (ESO)
- **Integration with AWS Secrets Manager**:
  - Secure secret synchronization between AWS Secrets Manager and Kubernetes
  - Automatic secret rotation with AWS Secrets Manager
  - IAM role-based access using EKS OIDC provider
  - KMS encryption support for all secrets
  - Environment-specific secret management (dev/staging/prod)

- **Architecture**:
  - Cluster-wide SecretStore for AWS integration
  - Namespace-specific ExternalSecret resources
  - Service account with IRSA (IAM Roles for Service Accounts)
  - Secure webhook for validation
  - Leader election for high availability

- **Security Features**:
  - Least privilege IAM policies
  - KMS encryption at rest
  - Non-root container execution
  - Pod security context
  - Resource limits and requests
  - Pod disruption budget
  - Pod anti-affinity for high availability

- **Monitoring and Observability**:
  - Prometheus metrics integration
  - ServiceMonitor for Prometheus Operator
  - Detailed audit logging
  - Webhook validation metrics
  - Leader election status

- **Usage Examples**:

  1. **Basic Secret**:
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

  2. **Secret with Template**:
  ```yaml
  apiVersion: external-secrets.io/v1beta1
  kind: ExternalSecret
  metadata:
    name: api-config
    namespace: my-app
  spec:
    refreshInterval: 1h
    secretStoreRef:
      name: aws-secrets-manager
      kind: ClusterSecretStore
    target:
      name: api-config
      template:
        type: Opaque
        data:
          config.json: |
            {
              "apiKey": "{{ .apiKey }}",
              "endpoint": "{{ .endpoint }}"
            }
    data:
      - secretKey: apiKey
        remoteRef:
          key: prod/api/credentials
          property: apiKey
      - secretKey: endpoint
        remoteRef:
          key: prod/api/config
          property: endpoint
  ```

  3. **Secret with DataFrom**:
  ```yaml
  apiVersion: external-secrets.io/v1beta1
  kind: ExternalSecret
  metadata:
    name: all-database-secrets
    namespace: my-app
  spec:
    refreshInterval: 1h
    secretStoreRef:
      name: aws-secrets-manager
      kind: ClusterSecretStore
    target:
      name: all-database-secrets
    dataFrom:
      - extract:
          key: prod/database/all-secrets
  ```

- **Best Practices**:
  - Use environment-specific secret paths
  - Implement proper secret rotation
  - Set appropriate refresh intervals
  - Use templates for complex secret structures
  - Monitor secret synchronization status
  - Regular audit of secret access
  - Implement proper RBAC for ExternalSecret resources

- **Troubleshooting**:
  - Check ESO pod logs for synchronization issues
  - Verify IAM role permissions
  - Ensure proper OIDC provider configuration
  - Monitor secret store status
  - Check webhook validation logs
  - Verify KMS key permissions

#### EKS Secrets Management
- **Cluster-level Encryption**:
  - KMS encryption for Kubernetes secrets
  - Private endpoint access
  - Certificate rotation for kubelet
  - Encrypted EBS volumes for nodes

- **Node Security**:
  - Encrypted root volumes with KMS
  - Automatic certificate rotation
  - Secure bootstrap process
  - IAM roles with least privilege

#### State and Backup Security
- **Terraform State**:
  - Encrypted S3 backend
  - DynamoDB state locking
  - Versioning enabled
  - Regular automated backups
  - 30-day retention policy

#### Security Monitoring
- **Audit and Compliance**:
  - CloudTrail logging with KMS encryption
  - AWS Config monitoring
  - GuardDuty threat detection
  - Regular security scanning

#### Access Control
- **IAM Integration**:
  - Role-based access control
  - Service-specific permissions
  - Least privilege principle
  - Regular access reviews

#### Compliance Features
- **HIPAA/GDPR Compliance**:
  - Encryption at rest
  - Secure key management
  - Audit logging
  - Access control
  - Regular key rotation

### Networking Modules
- **VPC**: Deploys multi-AZ VPC with private subnets and NAT gateways.
- **Transit Gateway**: Enables inter-VPC connectivity.
- **VPC Endpoints**: Provides private access to S3/DynamoDB.
- **Dependencies**: EKS depends on VPC and security groups.

### CI/CD Pipeline
- **Tools**: GitLab CI or AWS CodePipeline.
- **Stages**:
  - `terraform init`: Initialize providers and modules.
  - `terraform validate`: Check syntax.
  - `terraform plan`: Preview changes.
  - Terratest: Validate EKS cluster and microservices.
  - Checkov: Scan for security issues.
  - Manual approval for staging/prod.
  - `terraform apply`: Deploy infrastructure.
- **Notifications**: Slack alerts for pipeline status.

### Testing
- **Terratest**: Located in `tests/terratest` (e.g., `eks_test.go` for cluster validation).
- **Checkov**: Security scans in `tests/checkov`.
- Run tests in CI pipeline or locally:
  ```bash
  cd tests/terratest
  go test -v eks_test.go
  checkov -d .
  ```

### Drift Detection
- Use `scripts/drift-detection.sh` to run `terraform plan` in scheduled CI jobs.
- Monitor configuration drift for EKS resources.

## Terraform Best Practices
- **Modularity**: Use reusable modules in `modules/` with clear inputs/outputs.
- **State Management**: Store state in S3 with DynamoDB locking, encrypted with KMS.
- **Versioning**: Pin providers (`versions.tf`) and modules (e.g., `v1.0.0` in GitLab).
- **Validation**: Run `terraform validate` and `terraform plan` in CI.
- **Testing**: Use Terratest for functional validation and Checkov for security.
- **Drift Detection**: Schedule `terraform plan` to detect EKS configuration drift.
- **Cleanup**: Plan `terraform destroy` for deprecated resources.

## EKS Best Practices
- **Security**: Use private endpoints, IRSA, and pod security policies.
- **Compliance**: Enable control plane logging; encrypt EBS with KMS.
- **Reliability**: Configure auto-scaling node groups and multi-AZ deployments.
- **Observability**: Deploy Prometheus/Grafana via Helm, integrated with CloudWatch.

## Compliance
- **HIPAA/GDPR**:
  - Enable CloudTrail for EKS API auditing.
  - Use AWS Config to ensure encrypted EBS and private endpoints.
  - Isolate microservices data with pod security policies.
- **Tools**: GuardDuty for threat detection, AWS Config for compliance monitoring.

## Contributing
- Submit pull requests to GitLab with feature branches.
- Run pre-commit hooks (`.pre-commit-config.yaml`) for code quality.
- Document new modules in `modules/<name>/README.md`.

## Documentation
- **Architecture**: Diagrams in `docs/architecture`.
- **Compliance**: HIPAA/GDPR controls in `docs/compliance`.
- **Runbooks**: Operational guides in `docs/runbooks`.
