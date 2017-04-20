# My Highly Available Kubernetes Ansible
A vagrant development environment for Kubernetes and Ceph.

TODO:
- [x] Vagrant virtualbox scripts.
- [ ] Vagrant libvirt scripts.
- [x] Kubernetes HA cluster setup(v1.5.0+).
- [x] Kubernetes addons.
- [x] Ceph on Kubernetes(v11.2.0+).
- [x] Kubernetes Ceph RBD/FS volume.

## Quick Start
Following the below steps to create Kubernetes cluster on `CentOS 7.x` and `Ubuntu Server 16.x`.

Requirement:
* [Vagrant](https://www.vagrantup.com/downloads.html) >= 1.7.0
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 5.0.0

The getting started guide will use Vagrant with VirtualBox. It can deploy your Kubernetes cluster with a single command:
```sh
$ ./setup-vagrant -b 1 -n 3 -c 1 -m 1024
Cluster Size: 1 master, 3 node.
     VM Size: 1 vCPU, 1024 MB
Start deploying?(y): y
```

## Virtual machine and Bare machine Setup
Easy to create a Highly Available Kubernetes cluster using Ansible playbook.  

Requirement:
* Deploy node must be install `Ansible v2.0.0+`.
* All Master/Node should have password-less access from Deploy node.

Add the system information gathered above into a file called `inventory`. For inventory example:
```
[etcd]
172.16.35.13

[masters]
172.16.35.13

[sslhost]
172.16.35.13

[nodes]
172.16.35.10
172.16.35.11
172.16.35.12
```

Set the variables in `group_vars/all.yml` to reflect you need options.

If everything is ready, just run `cluster.yml` to deploy cluster:
```sh
$ ansible-playbook -i inventory cluster.yml
```

And then run `addons.yml` to create addons(Dashboard, proxy, DNS):
```sh
$ ansible-playbook -i inventory addons.yml
```

If you want to deploy a Ceph cluster on to a Kubernetes, just run `ceph-cluster.yml`:
```sh
$ ansible-playbook -i inventory ceph-cluster.yml
```

When Ceph cluster is fully running, you must label your storage nodes in order to run osd pods on them:
```sh
$ kubectl label node <node_name> node-type=storage
```

## Verify cluster
If all step completed, you can run following the below command:
```sh
$ kubectl get po,svc --namespace=kube-system

NAME                                 READY     STATUS    RESTARTS   AGE       IP             NODE
po/haproxy-master1                   1/1       Running   0          2h        172.16.35.13   master1
po/kube-apiserver-master1            1/1       Running   0          2h        172.16.35.13   master1
po/kube-controller-manager-master1   1/1       Running   1          2h        172.16.35.13   master1
po/kube-dns-v20-sp2xj                3/3       Running   0          2h        172.20.3.2     node3
po/kube-proxy-amd64-4g4kn            1/1       Running   0          2h        172.16.35.12   node3
po/kube-proxy-amd64-cqbnk            1/1       Running   0          2h        172.16.35.11   node2
po/kube-proxy-amd64-d7l1p            1/1       Running   0          2h        172.16.35.10   node1
po/kube-proxy-amd64-f2wqq            1/1       Running   0          2h        172.16.35.13   master1
po/kube-scheduler-master1            1/1       Running   2          2h        172.16.35.13   master1

NAME           CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE       SELECTOR
svc/kube-dns   192.160.0.10   <none>        53/UDP,53/TCP   2h        k8s-app=kube-dns
```

Check ceph cluster is running:
```sh
$ kubectl get po,svc --namespace=ceph

NAME                                 READY     STATUS    RESTARTS   AGE       IP            NODE
po/ceph-mds-2743106415-gccj5         1/1       Running   0          1h        172.20.67.4   node1
po/ceph-mon-246094207-6r9g6          1/1       Running   0          1h        172.20.67.2   node1
po/ceph-mon-246094207-hx0md          1/1       Running   1          1h        172.20.77.3   node2
po/ceph-mon-246094207-pv3b0          1/1       Running   0          1h        172.20.3.3    node3
po/ceph-mon-check-1896585268-4m9sw   1/1       Running   0          1h        172.20.77.2   node2
po/ceph-osd-5m9hw                    1/1       Running   0          1h        172.20.3.4    node3
po/ceph-osd-qn5qt                    1/1       Running   0          1h        172.20.77.4   node2
po/ceph-osd-r7251                    1/1       Running   0          1h        172.20.67.3   node1

NAME           CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE       SELECTOR
svc/ceph-mon   None         <none>        6789/TCP   1h        app=ceph,daemon=mon
```

Get ceph status using kubectl exec:
```sh
$ kubectl --namespace=ceph exec -ti ceph-mon-246094207-6r9g6 -- ceph -s

cluster bafca3e9-b361-464c-b8fa-04bf60b3189f
 health HEALTH_OK
 monmap e2: 1 mons at {ceph-mon-246094207-6r9g6=172.20.67.2:6789/0}
        election epoch 4, quorum 0 ceph-mon-246094207-6r9g6
  fsmap e5: 1/1/1 up {0=mds-ceph-mds-2743106415-gccj5=up:active}
    mgr no daemons active
 osdmap e17: 3 osds: 3 up, 3 in
        flags sortbitwise,require_jewel_osds,require_kraken_osds
  pgmap v1813: 80 pgs, 3 pools, 2148 bytes data, 20 objects
        32751 MB used, 83338 MB / 113 GB avail
              80 active+clean
```

## Nginx application example
Run a simple nginx application:
```sh
$ kubectl create -f examples/nginx/
$ kubectl get svc,po -o wide
```
