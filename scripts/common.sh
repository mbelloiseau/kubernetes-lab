#!/bin/bash

set -e

KUBERNETES_VERSION="1.25.5-00"

apt update >/dev/null 2>&1
apt install -y apt-transport-https ca-certificates curl vim bash-completion >/dev/null 2>&1

swapoff -a
sed -i '/swap/ s/./#&/' /etc/fstab

echo -e "overlay\nbr_netfilter" > /etc/modules-load.d/k8s.conf
modprobe overlay
modprobe br_netfilter

test -f /etc/sysctl.d/k8s.conf && rm /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/k8s.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/k8s.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/k8s.conf
sysctl -p /etc/sysctl.d/k8s.conf

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl enable --now containerd
systemctl restart containerd

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --batch --yes --dearmor -o /etc/apt/keyrings/kubernetes.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt update
apt-get install -qqy kubelet=${KUBERNETES_VERSION} kubeadm=${KUBERNETES_VERSION} kubectl=${KUBERNETES_VERSION}
apt-mark hold kubelet kubeadm kubectl
