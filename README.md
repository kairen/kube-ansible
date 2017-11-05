# Highly Available Kubernetes Ansible Playbooks
Ansible playbooks for quickly building Kubernetes and Ceph cluster.

Feature list:
- [x] Vagrant VirtualBox and Libvirt.
- [x] Kubernetes HA cluster setup(v1.7.0+).
- [x] Kubernetes addons.
- [x] Ceph on Kubernetes(v10.2.0+).
- [x] Kubernetes Ceph RBD/FS volume.

[![asciicast](https://asciinema.org/a/YjC8qJshj47pVndOLBFRQ7iai.png)](https://asciinema.org/a/YjC8qJshj47pVndOLBFRQ7iai?speed=2)

## Quick Start
Following the below steps to create Kubernetes cluster on `CentOS 7.x` and `Ubuntu Server 16.x`.

Requirement:
* [Vagrant](https://www.vagrantup.com/downloads.html) >= 1.7.0
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 5.0.0

The getting started guide will use Vagrant with VirtualBox. It can deploy your Kubernetes cluster with a single command:
```sh
$ ./setup-vagrant -w 3 -n calico
Cluster Size: 1 master, 3 worker.
     VM Size: 1 vCPU, 2048 MB
     VM Info: ubuntu16, virtualbox
         CNI: calico
Start deploying?(y): y
```
> Using libvirt provider:
```sh
$ sudo ./setup-vagrant -p libvirt -i eth1
```

Login addon's dashboard:
* [Dashboard](https://<API_SERVER>:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/)。
* [Logging](https://<API_SERVER>:6443/api/v1/proxy/namespaces/kube-system/services/kibana-logging)。
* [Monitoring](https://<API_SERVER>:6443/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana)。

## Manually Set Up
Easy to create a Highly Available Kubernetes cluster using Ansible playbook.  

Requirement:
* Deploy node must be install `Ansible v2.4.0+`.
* All Master/Node should have password-less access from `Deploy` node.

For machine example:

| IP Address      |   Role           |   CPU    |   Memory   |
|-----------------|------------------|----------|------------|
| 172.16.35.9     | vip              |    -     |     -      |
| 172.16.35.13    | master1 + deploy |    2     |     4G     |
| 172.16.35.10    | node1            |    2     |     4G     |
| 172.16.35.11    | node2            |    2     |     4G     |
| 172.16.35.12    | node3            |    2     |     4G     |

Add the system information gathered above into a file called `inventory`. For inventory example:
```
[etcds]
172.16.35.13

[masters]
172.16.35.13

[nodes]
172.16.35.10
172.16.35.11
172.16.35.12

[kube-cluster:children]
masters
nodes
```

Set the variables in `group_vars/all.yml` to reflect you need options. For example:
```yml
kube_version: 1.8.1
network: calico
lb_vip_address: 172.16.35.9
```

### Deploy a Kubernetes cluster
If everything is ready, just run `cluster.yml` to deploy cluster:
```sh
$ ansible-playbook cluster.yml
```

And then run `addons.yml` to create addons(Dashboard, Proxy, DNS):
```sh
$ ansible-playbook addons.yml
```

### Deploy Ceph cluster on Kubernetes
If you want to deploy a Ceph cluster on to a Kubernetes, just run `ceph-k8s.yml`:
```sh
$ ansible-playbook ceph-k8s.yml
```

When Ceph cluster is fully running, you must label your storage nodes in order to run osd pods on them:
```sh
$ kubectl label node <node_name> node-type=storage
```

## Verify cluster
Now, check the service as follow:
```sh
$ kubectl get po,svc --namespace=kube-system

NAME                                 READY     STATUS    RESTARTS   AGE       IP             NODE
po/haproxy-master1                   1/1       Running   0          2h        172.16.35.13   master1
...
```

Check ceph cluster is running:
```sh
$ kubectl get po,svc --namespace=ceph

NAME                                 READY     STATUS    RESTARTS   AGE       IP            NODE
po/ceph-mds-2743106415-gccj5         1/1       Running   0          1h        172.20.67.4   node1
po/ceph-mon-246094207-6r9g6          1/1       Running   0          1h        172.20.67.2   node1
...
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

## Run a simple application for Nginx
First, get example submodules that need to be checked out with:
```sh
$ git submodule update --init --recursive
```

Run a simple nginx application:
```sh
$ kubectl create -f examples/nginx/
$ kubectl get svc,po -o wide
```

## Reset cluster and Tear down node
Reset all kubernetes cluster installed state:
```sh
$ ansible-playbook reset.yml
```

Tear down node using the follow command:
```sh
$ ansible-playbook extra-playbooks/node/del.yml
Which nodes would you like to delete? node2

$ ansible-playbook reset.yml --tags kube -e hosts=node2
```
