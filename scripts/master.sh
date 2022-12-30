#!/bin/bash

KUBERNETES_POD_NETWORK="172.18.0.0/16"
MASTER_IP="192.168.60.10"

# check if a k8s cluster is already up and running
kubectl cluster-info > /dev/null 2>&1
if [ $? -eq 0 ] ; then
	exit 0
fi

kubeadm config images pull

kubeadm init --apiserver-advertise-address=${MASTER_IP} \
	--apiserver-cert-extra-sans=${MASTER_IP},$(hostname -s),localhost \
	--node-name=$(hostname -s) \
	--pod-network-cidr=${KUBERNETES_POD_NETWORK}

mkdir -p "${HOME}"/.kube
cp -i /etc/kubernetes/admin.conf "${HOME}"/.kube/config
chown "$(id -u)":"$(id -g)" "${HOME}"/.kube/config

cp -f /etc/kubernetes/admin.conf /opt/shared/$(hostname -s).conf

# check if we're in a vagrant box
id vagrant > /dev/null 2>&1
if [ $? -eq 0 ] ; then
	VAGRANT_HOME=$(eval echo "~vagrant")
	mkdir -p "${VAGRANT_HOME}"/.kube
	cp -i /etc/kubernetes/admin.conf "${VAGRANT_HOME}"/.kube/config
	chown "$(id -u vagrant)":"$(id -g vagrant)" "${VAGRANT_HOME}"/.kube/config
	echo 'source <(kubectl completion bash)' >> "${VAGRANT_HOME}"/.bashrc
fi

# generate join command for workers
kubeadm token create --print-join-command > /vagrant/shared/join.sh

exit 0
