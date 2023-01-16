#!/usr/bin/env bash

(test -f ./shared/k8s-master.conf && export KUBECONFIG=./shared/k8s-master.conf) || (echo "./shared/k8s-master.conf is missing" && exit 1)

kubectl cluster-info | grep -q "192.168.60.10:6443"

if [ $? -ne 0 ] ; then
    echo "Something goes wrong"
    exit 1
fi

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

sleep 5

NON_RUNNING_POD=$(kubectl get pod --all-namespaces --field-selector='status.phase!=Running' --no-headers | wc -l)

while [ ${NON_RUNNING_POD} -ne 0 ]
do
  echo "${NON_RUNNING_POD} pods are not ready, please wait"
  sleep 5
  NON_RUNNING_POD=$(kubectl get pod --all-namespaces --field-selector='status.phase!=Running' --no-headers | wc -l)
done

cat <<EOF | kubectl apply -n metallb-system -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.60.50-192.168.60.60
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF
