locals {
  name = "${var.project_name}-${var.environment}"
}

# Helm release for External Secrets Operator
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = var.chart_version

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }

  set {
    name  = "securityContext.fsGroup"
    value = "65534"
  }

  set {
    name  = "securityContext.runAsUser"
    value = "65534"
  }

  set {
    name  = "securityContext.runAsNonRoot"
    value = "true"
  }

  values = [
    templatefile("${path.module}/templates/values.yaml", {
      cluster_name = var.cluster_name
    })
  ]

  depends_on = [
    aws_iam_role.external_secrets,
    aws_iam_role_policy.external_secrets
  ]
}

# IAM role for External Secrets Operator
resource "aws_iam_role" "external_secrets" {
  name = "${local.name}-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for External Secrets Operator
resource "aws_iam_role_policy" "external_secrets" {
  name = "${local.name}-external-secrets-policy"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:*",
          var.kms_key_arn
        ]
      }
    ]
  })
}

# Example ExternalSecret resource
resource "kubernetes_manifest" "example_secret" {
  count = var.create_example_secret ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "example-secret"
      namespace = "default"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets-manager"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "example-secret"
      }
      data = [
        {
          secretKey = "username"
          remoteRef = {
            key = "example/secret"
            property = "username"
          }
        },
        {
          secretKey = "password"
          remoteRef = {
            key = "example/secret"
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [helm_release.external_secrets]
}

# Example SecretStore resource
resource "kubernetes_manifest" "aws_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
          auth = {
            jwt = {
              serviceAccountRef = {
                name = "external-secrets"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.external_secrets]
} 