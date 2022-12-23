# kubernetes-lab

## Purposes

Build a local bare metal Kubernetes cluster with Vagrant (1 master 2 workers) with the following components
* [Calico](https://projectcalico.docs.tigera.io/getting-started/kubernetes/) for networking
* [MetalLB](https://metallb.universe.tf/) as load-balancer
* [Nginx ingress controller](https://docs.nginx.com/nginx-ingress-controller/)
  
## Requirements

* Vagrant
* Virtualbox
* At least 16Go on your computeur

I'm currently working with Vagrant 2.3.4 and VirtualBox 6.1.38 (6.1.38-dfsg-3~ubuntu1.22.04.1) but it should work any other version.

## Architecture

```                                                                                                                                                                                            
                                                        +---------------------+               
                                                        | Guest k8s-worker-1  |               
                                                        |                     |               
+-----------------------+    +----------------------+   | eth1 192.168.60.11  |               
| Host                  |    |  Guest k8s-master    |   +---------------------+               
|                       |    |                      |                                         
| vboxnet0 192.168.60.1 |    |  eth1 192.168.60.10  |   +---------------------+               
+-----------------------+    +----------------------+   | Guest k8s-worker-2  |               
                                                        |                     |               
                                                        | eth1 192.168.60.12  |               
                                                        +---------------------+          
```

## Usage

```
$ git clone https://github.com/mbelloiseau/kubernetes-lab
$ cd kubernetes-lab
$ vagrant up
```

## Configuration

> The following commands can be directly executed from your computer with `vagrant ssh k8s-master -- <command>` or inside the virtual machine after `vagrant ssh`

After `vagrant up` our VMs are installed by our Kubernetes cluster is not functionnal.

```
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

```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

If needed we can install `calicoctl` as a Kubernetes pod

```
$ kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/calicoctl.yaml
$ kubectl exec -ti -n kube-system calicoctl -- /calicoctl ipam show
+----------+---------------+-----------+------------+--------------+
| GROUPING |     CIDR      | IPS TOTAL | IPS IN USE |   IPS FREE   |
+----------+---------------+-----------+------------+--------------+
| IP Pool  | 172.18.0.0/16 |     65536 | 6 (0%)     | 65530 (100%) |
+----------+---------------+-----------+------------+--------------+
```

### MetalLB



```
$ kubectl apply -f https://raw.githubusercontent.com/mbelloiseau/kubernetes-lab/vagrant/manifests/metallb/metallb.yml
```

We can now create a simple deployment and expose it

```
$ kubectl create deployment --image nginx nginx
deployment.apps/nginx created
$ kubectl expose deployment nginx --port 80 --type LoadBalancer
service/nginx exposed
$ kubectl get services nginx -o jsonpath='{.status.loadBalancer.ingress[*].ip}'
192.168.60.50
```

You should be able to reach the displayed IP adress (192.168.60.50 in our example) on port 80 from your computeur.

### Nginx ingress controler

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
kubectl create deployment httpd --image=httpd --port=80
kubectl expose deployment httpd
kubectl create ingress httpd --class=nginx --rule app.domain.tld/=httpd:80
kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
curl -H "Host: app.domain.tld" -I $(kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
kubectl logs -n ingress-nginx service/ingress-nginx-controller -f
```