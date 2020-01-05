#!/bin/bash

exec &> /var/log/init-kube.log

set -o verbose
set -o errexit
set -o pipefail
set -o nounset

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Install Docker and Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y kubelet=${k8s_version}-00 kubeadm=${k8s_version}-00 kubectl=${k8s_version}-00 docker.io
apt-mark hold kubelet kubeadm kubectl docker.io

# Enable overlay network
cat > /etc/sysctl.d/99-kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
service procps start

# Ensure Docker cgroup uses systemd driver
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl enable docker
systemctl restart docker

# Setup cluster using kubeadm
cat > init-kubeadm.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: "${admin_token}"
  ttl: 0s
  usages:
  - signing
  - authentication
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws
  name: "$(curl -s http://169.254.169.254/latest/meta-data/hostname)"
  taints: []
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
apiServer:
  certSANs:
  - ${dns_name}
  - ${ip_address}
  extraArgs:
    cloud-provider: aws
clusterName: ${cluster_name}
controllerManager:
  extraArgs:
    cloud-provider: aws
kubernetesVersion: v${k8s_version}
networking:
  podSubnet: 10.244.0.0/16
EOF
kubeadm init --config=init-kubeadm.yaml

# Configure kubelet
echo 'KUBELET_EXTRA_ARGS="--cloud-provider=aws"' > /etc/default/kubelet
systemctl enable kubelet
systemctl start kubelet

# Setup kubectl for `ubuntu` user
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Setup Flannel network
su -c 'kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/023dc119c068d94590b2040d6550ff5ecfa190da/Documentation/kube-flannel.yml' ubuntu

# Install Helm
wget https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz
tar xvf helm-v${helm_version}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64 helm-*
