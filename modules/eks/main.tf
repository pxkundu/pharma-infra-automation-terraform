locals {
  cluster_name = "${var.project_name}-${var.environment}-cluster"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_access
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]

  tags = var.tags
}

# Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = var.node_instance_types

  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = var.tags
}

# Launch Template for Node Group
resource "aws_launch_template" "node" {
  name_prefix   = "${local.cluster_name}-node-"
  image_id      = var.node_ami_id
  instance_type = var.node_instance_types[0]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id           = var.kms_key_arn
      delete_on_termination = true
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.node.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    cluster_name = local.cluster_name
    cluster_endpoint = aws_eks_cluster.main.endpoint
    cluster_ca = aws_eks_cluster.main.certificate_authority[0].data
  }))
}

# Security Groups
resource "aws_security_group" "cluster" {
  name_prefix = "${local.cluster_name}-cluster-"
  vpc_id      = var.vpc_id
  description = "Security group for EKS cluster"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cluster_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.cluster_name}-cluster-sg"
  })
}

resource "aws_security_group" "node" {
  name_prefix = "${local.cluster_name}-node-"
  vpc_id      = var.vpc_id
  description = "Security group for EKS nodes"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.cluster.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.cluster_name}-node-sg"
  })
}

# External Secrets Operator
module "external_secrets" {
  source = "../security/external-secrets-operator"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = local.cluster_name

  cluster_oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  cluster_oidc_issuer_url   = aws_iam_openid_connect_provider.eks.url
  
  aws_region    = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
  kms_key_arn   = var.kms_key_arn

  tags = var.tags
} 