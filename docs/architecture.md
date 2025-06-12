# Architecture Diagram Documentation

## Overview
This document provides architecture diagrams for the Terraform-based EKS infrastructure automation project, illustrating the deployment of a secure, scalable, HIPAA/GDPR-compliant Amazon Elastic Kubernetes Service (EKS) infrastructure for containerized microservices in a Fortune 100 medical/pharmaceutical company. The diagrams cover the high-level architecture, networking, security, and EKS-specific components.

## Diagrams
### 1. High-Level Architecture
**Description**: Overview of the multi-account AWS environment with EKS clusters and supporting services.
**Diagram**:
```
+----------------------------- AWS Organization -----------------------------+
|                                                                           |
| +------------+  +------------+  +------------+  +------------+            |
| | Security   |  | Shared     |  | Dev        |  | Staging/Prod |            |
| | Account    |  | Services   |  | Account    |  | Account     |            |
| |            |  |            |  |            |  |             |            |
| | - CloudTrail | - Global IAM | - EKS Cluster | - EKS Cluster |            |
| | - AWS Config | - S3 Backend | - Microservices | - Microservices |         |
| | - GuardDuty |              | - VPC         | - VPC         |            |
| +------------+  +------------+  +------------+  +------------+            |
|                                                                           |
+---------------------------------------------------------------------------+
       |                       |                       |
       v                       v                       v
   Centralized Logging    Shared Resources      Environment-Specific Infra
```

**Key Components**:
- **Security Account**: Hosts CloudTrail, AWS Config, and GuardDuty for centralized compliance and monitoring.
- **Shared Services Account**: Manages S3/DynamoDB backend for Terraform state and global IAM policies.
- **Dev/Staging/Prod Accounts**: Deploy EKS clusters, VPCs, and microservices.

### 2. EKS Cluster Architecture
**Description**: Detailed view of the EKS cluster setup within an environment.
**Diagram**:
```
+----------------------- VPC (Multi-AZ) -----------------------+
|                                                             |
| +----------------- Private Subnet (AZ1) -----------------+  |
| |                                                       |  |
| | +-----------+  +-----------+  +-----------+           |  |
| | | EKS       |  | Managed   |  | Fargate   |           |  |
| | | Control   |  | Node Group|  | Profile   |           |  |
| | | Plane     |  | (Auto-scaling) | (Stateless) |       |  |
| | +-----------+  +-----------+  +-----------+           |  |
| |                                                       |  |
| | +-----------+  +-----------+                          |  |
| | | Microservices Pods (Clinical Data API, EMR)       |  |
| | | - AWS Load Balancer Controller                   |  |
| | | - Cluster Autoscaler                            |  |
| | +---------------------------------------------+    |  |
| +---------------------------------------------------+    |
|                                                             |
| +----------------- Private Subnet (AZ2) -----------------+  |
| | Similar setup for high availability                   |  |
| +---------------------------------------------------+    |
|                                                             |
| +----------------- Public Subnet (AZ1) ------------------+  |
| | +-----------+                                         |  |
| | | NAT Gateway |                                       |  |
| | +-----------+                                         |  |
| +---------------------------------------------------+    |
|                                                             |
| +------------------- VPC Endpoints ----------------------+  |
| | S3, DynamoDB for private access                       |  |
| +---------------------------------------------------+    |
|                                                             |
+----------------------- Transit Gateway ---------------------+
                        | Connects to other VPCs/On-Prem |
                        +-----------------------------------+
```

**Key Components**:
- **EKS Cluster**: Private control plane with logging enabled.
- **Node Groups**: Managed, auto-scaling nodes with encrypted EBS.
- **Fargate Profiles**: Serverless compute for stateless microservices.
- **Microservices**: Deployed via Helm (e.g., clinical data APIs).
- **Networking**: Private subnets, NAT gateways, VPC endpoints, and Transit Gateway.

### 3. Security and Compliance Architecture
**Description**: Illustrates security and compliance components integrated with EKS.
**Diagram**:
```
+----------------------- Security Account ---------------------+
|                                                             |
| +-----------+  +-----------+  +-----------+                |
| | CloudTrail |  | AWS Config |  | GuardDuty |              |
| | (EKS APIs) |  | (Compliance |  | (Threat   |              |
| |            |  |  Rules)    |  | Detection)|              |
| +-----------+  +-----------+  +-----------+                |
|         |            |            |                        |
|         v            v            v                        |
| +-----------+                                             |
| | S3 Bucket |                                             |
| | (Logs)    |                                             |
| +-----------+                                             |
|                                                             |
+----------------------- EKS Account -------------------------+
|                                                             |
| +-----------+  +-----------+  +-----------+                |
| | IAM Roles |  | KMS Keys  |  | Secrets   |                |
| | (IRSA)    |  | (EBS, S3) |  | Manager   |                |
| +-----------+  +-----------+  +-----------+                |
|         |            |            |                        |
|         v            v            v                        |
| +---------------- EKS Cluster --------------------------+  |
| | Microservices with Pod Security Policies            |  |
| | Prometheus/Grafana for Monitoring                  |  |
| +---------------------------------------------------+    |
|                                                             |
+-----------------------------------------------------------+
```

**Key Components**:
- **Security Account**: Centralized CloudTrail, AWS Config, and GuardDuty.
- **EKS Account**: IAM roles with IRSA, KMS encryption, Secrets Manager, and pod security policies.
- **Monitoring**: Prometheus/Grafana integrated with CloudWatch.

## Location
- Diagrams are stored in `docs/architecture/` as markdown and image files (e.g., PNGs generated with tools like Draw.io or Lucidchart).
- Refer to `docs/architecture/high-level-architecture.png`, `eks-cluster.png`, and `security-compliance.png` for visual representations.