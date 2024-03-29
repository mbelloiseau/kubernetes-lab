# kubernetes-lab

## Purpose

Build a local bare metal Kubernetes cluster with Vagrant (1 master 2 workers) with the following components

* [Calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/) as CNI plugin
* [MetalLB](https://metallb.universe.tf/) as load-balancer (in layer 2 mode)
  
## Requirements

* Vagrant
* Virtualbox
* At least 16Go on your computeur

I'm currently working with Vagrant 2.3.4 and VirtualBox 6.1.38 (6.1.38-dfsg-3~ubuntu1.22.04.1) but it should work any other version.

## Architecture

![architecture](.plantuml/out/architecture/architecture.png)

## Usage

```bash
git clone https://github.com/mbelloiseau/kubernetes-lab
cd kubernetes-lab
vagrant up
```

## Configuration

> The following commands can be directly executed from your computer with `vagrant ssh k8s-master -- <command>` or inside the k8s-master virtual machine after `vagrant ssh k8s-master`

After `vagrant up` our VMs are installed but our Kubernetes cluster is not fully functional.

```console
$ kubectl get nodes
NAME           STATUS     ROLES           AGE     VERSION
k8s-master     NotReady   control-plane   8m35s   v1.25.5
k8s-worker-1   NotReady   <none>          5m16s   v1.25.5
k8s-worker-2   NotReady   <none>          110s    v1.25.5

$ kubectl get pods -n kube-system --field-selector status.phase!=Running
NAME                       READY   STATUS    RESTARTS   AGE
coredns-565d847f94-4hjj6   0/1     Pending   0          6m18s
coredns-565d847f94-w25gz   0/1     Pending   0          6m17s
```

### Calico

We need to install a CNI plugin, I'm using Calico but there's some alternatives (see https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy)

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### MetalLB

When you deploy a bare-metal Kubernetes cluster it does not come with a network load balancer. MetalLB is a solution.

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
```

```bash
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
```

See [MetalLB documentation](https://metallb.universe.tf/configuration/) for more details.

We can now create a simple deployment and expose it

```bash
kubectl create namespace demo
kubectl create deployment -n demo --image nginx nginx
kubectl expose deployment -n demo nginx --port 80 --type LoadBalancer
kubectl get services -n demo nginx -o jsonpath='{.status.loadBalancer.ingress[*].ip}'
```

You should be able to reach the displayed IP adress on port 80 from your computer.