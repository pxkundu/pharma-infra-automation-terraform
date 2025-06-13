# Terraform Modules

## Overview
This directory contains reusable Terraform modules for the pharmaceutical infrastructure automation project. Each module is designed to be self-contained and follows infrastructure-as-code best practices.

## Module Structure

### EKS Module (`eks/`)
- EKS cluster configuration
- Node group management
- IAM roles and policies
- Security group setup
- External Secrets Operator integration

### VPC Module (`vpc/`)
- VPC configuration
- Subnet management
- Route tables
- Network ACLs
- VPC endpoints

### KMS Module (`kms/`)
- KMS key creation
- Key policy management
- Alias configuration
- Key rotation setup

### Security Module (`security/`)
- IAM policies
- Security groups
- Network policies
- Compliance configurations

## Module Usage

### Example Usage
```hcl
module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

  kubernetes_version    = var.kubernetes_version
  enable_public_access  = var.enable_public_access
  cluster_ingress_cidrs = var.cluster_ingress_cidrs

  node_ami_id         = var.node_ami_id
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_max_size       = var.node_max_size
  node_min_size       = var.node_min_size
  node_disk_size      = var.node_disk_size

  kms_key_arn = module.kms.kms_key_arn
  tags        = var.tags
}
```

## Module Development

### Best Practices
1. Use consistent variable naming
2. Include comprehensive documentation
3. Implement proper error handling
4. Follow security best practices
5. Include example configurations

### Testing
- Use Terratest for module testing
- Include test cases for each module
- Validate security configurations
- Test error scenarios

### Documentation
- Include README.md in each module
- Document all variables and outputs
- Provide usage examples
- Include security considerations

## Module Maintenance

### Version Control
- Use semantic versioning
- Document breaking changes
- Maintain changelog
- Tag releases

### Updates
- Regular security updates
- Performance optimizations
- Feature additions
- Bug fixes

## Security

### Access Control
- Least privilege principle
- IAM role management
- Security group rules
- Network policies

### Compliance
- HIPAA requirements
- Data encryption
- Audit logging
- Security monitoring

## References
- [Terraform Module Documentation](https://www.terraform.io/language/modules)
- [AWS EKS Best Practices](https://docs.aws.amazon.com/eks/latest/userguide/best-practices.html)
- [Infrastructure as Code Best Practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/implementing-infrastructure-as-code/welcome.html) 