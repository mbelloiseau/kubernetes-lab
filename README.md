# kubernetes-lab
Kubernetes lab

## purposes

## lab

### requirements

* Vagrant (I'm working with version 2.3.4)
* Virtualbox (I'm working with version 6.1.38-dfsg-3~ubuntu1.22.04.1)
* At least 16Go on your computeur

I'm currently working with Vagrant 2.3.4 and VirtualBox 6.1.38 (6.1.38-dfsg-3~ubuntu1.22.04.1) but it should work any other version.

### usage

```bash
$ git clone https://github.com/mbelloiseau/kubernetes-lab
$ cd kubernetes-lab
$ vagrant up
$ vagrant ssh k8s-master -- kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
k8s-master     Ready    control-plane   24m   v1.25.5
k8s-worker-1   Ready    <none>          22m   v1.25.5
k8s-worker-2   Ready    <none>          21m   v1.25.5
```

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