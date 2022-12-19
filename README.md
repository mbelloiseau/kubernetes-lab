# kubernetes-lab
Kubernetes lab

## purposes

## lab

### requirements

* Vagrant
* Virtualbox
* At least 16Go on your computeur

I'm currently working with Vagrant 2.3.4 and VirtualBox 6.1.38 (6.1.38-dfsg-3~ubuntu1.22.04.1) but it should work any other version.

### usage

```
$ git clone https://github.com/mbelloiseau/kubernetes-lab
$ cd kubernetes-lab
$ vagrant up
```

> The following commands can be directly executed from your computer with `vagrant ssh k8s-master -- <command>` or inside the virtual machine after `vagrant ssh`

Once `vagrant up` is done you can finalize the MetalLB configuration

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

### architecture

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
