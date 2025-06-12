#!/bin/bash
set -o xtrace

# Install necessary packages
yum update -y
yum install -y amazon-efs-utils amazon-ssm-agent

# Configure kubelet
cat <<EOF > /etc/kubernetes/kubelet/kubelet-config.json
{
  "kind": "KubeletConfiguration",
  "apiVersion": "kubelet.config.k8s.io/v1beta1",
  "authentication": {
    "anonymous": {
      "enabled": false
    },
    "webhook": {
      "cacheTTL": "2m0s",
      "enabled": true
    },
    "x509": {
      "clientCAFile": "/etc/kubernetes/pki/ca.crt"
    }
  },
  "authorization": {
    "mode": "Webhook",
    "webhook": {
      "cacheAuthorizedTTL": "5m0s",
      "cacheUnauthorizedTTL": "30s"
    }
  },
  "clusterDomain": "cluster.local",
  "clusterDNS": ["10.100.0.10"],
  "cgroupDriver": "systemd",
  "cgroupRoot": "/",
  "featureGates": {
    "RotateKubeletServerCertificate": true
  },
  "protectKernelDefaults": true,
  "seccompDefault": true,
  "tlsCertFile": "/etc/kubernetes/pki/kubelet.crt",
  "tlsPrivateKeyFile": "/etc/kubernetes/pki/kubelet.key"
}
EOF

# Configure containerd
cat <<EOF > /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    sandbox_image = "602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/pause:3.5"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
EOF

# Start and enable services
systemctl daemon-reload
systemctl enable containerd
systemctl enable kubelet
systemctl start containerd
systemctl start kubelet

# Configure EKS bootstrap script
cat <<EOF > /etc/eks/bootstrap.sh
#!/bin/bash
set -o xtrace

# Set required variables
CLUSTER_NAME="${cluster_name}"
API_SERVER_ENDPOINT="${cluster_endpoint}"
CERTIFICATE_AUTHORITY="${cluster_ca}"

# Configure kubelet
cat <<EOF > /etc/kubernetes/kubelet/kubelet-config.json
{
  "kind": "KubeletConfiguration",
  "apiVersion": "kubelet.config.k8s.io/v1beta1",
  "authentication": {
    "anonymous": {
      "enabled": false
    },
    "webhook": {
      "cacheTTL": "2m0s",
      "enabled": true
    },
    "x509": {
      "clientCAFile": "/etc/kubernetes/pki/ca.crt"
    }
  },
  "authorization": {
    "mode": "Webhook",
    "webhook": {
      "cacheAuthorizedTTL": "5m0s",
      "cacheUnauthorizedTTL": "30s"
    }
  },
  "clusterDomain": "cluster.local",
  "clusterDNS": ["10.100.0.10"],
  "cgroupDriver": "systemd",
  "cgroupRoot": "/",
  "featureGates": {
    "RotateKubeletServerCertificate": true
  },
  "protectKernelDefaults": true,
  "seccompDefault": true,
  "tlsCertFile": "/etc/kubernetes/pki/kubelet.crt",
  "tlsPrivateKeyFile": "/etc/kubernetes/pki/kubelet.key"
}
EOF

# Configure kubeconfig
mkdir -p /etc/kubernetes
cat <<EOF > /etc/kubernetes/kubeconfig
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${API_SERVER_ENDPOINT}
    certificate-authority-data: ${CERTIFICATE_AUTHORITY}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet
current-context: kubelet
users:
- name: kubelet
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${CLUSTER_NAME}"
EOF

# Start kubelet
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
EOF

chmod +x /etc/eks/bootstrap.sh 