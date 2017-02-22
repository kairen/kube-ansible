# My Kubernetes and Ceph development environment
A vagrant development environment for Kubernetes and Ceph

If you want use this vagrant files, you must install the following of plugins:
```sh
$ vagrant plugin install vagrant-libvirt
```

TODO:
- [x] Vagrant scripts.
- [x] Kubernetes cluster setup(v1.4.6+).
- [ ] Ceph cluster setup.
- [ ] Kubernetes Ceph RBD/FS volume.
- [ ] Support vagrant-openstack.

## Quick Start
Following the below steps to create Kubernetes setup on `CentOS 7.x` and `Ubuntu Server 16.x` .

The getting started guide will use Vagrant with VirtualBox. It can deploy your Kubernetes cluster with a single command:
```sh
$ ./setup-vagrant.sh
```

### Requirement
* Deploy node need install Ansible.
* All master/node should have password-less access from Deploy node.

### VM and BareMetal Setup
Add the system information gathered above into a file called inventory.

For example(kubernetes):
```
[etcd]
172.16.35.12

[masters]
172.16.35.12

[sslhost]
172.16.35.12

[node]
172.16.35.10
172.16.35.11
```

Set the variables in `group_vars/all.yml` to reflect you need options.
> P.S. if using vagrant machine, you must modify `roles/node/defaults/main.yml` and `roles/etcd/defaults/main.yaml` bind interface.

Finally, running the `cluster-site.yml` to deploy cluster:
```sh
$ ansible-playbook -i inventory cluster-site.yml
```

(Option)Running the `addons-site.yml` to deploy addon:
```sh
$ ansible-playbook -i inventory addons-site.yml
```
> P.S. Require the cluster is fully operation and running

## Verify
If all step completed, you can run following the below command:
```sh
$ kubectl get po,svc --all-namespaces

NAMESPACE     NAME                                       READY     STATUS    RESTARTS   AGE
kube-system   po/haproxy-master1                         1/1       Running   0          2h
kube-system   po/kube-apiserver-master1                  1/1       Running   0          2h
kube-system   po/kube-controller-manager-master1         1/1       Running   0          2h
kube-system   po/kube-proxy-amd64-3f447                  1/1       Running   0          2h
kube-system   po/kube-proxy-amd64-j1ctw                  1/1       Running   0          2h
kube-system   po/kube-proxy-amd64-zsldl                  1/1       Running   0          2h
kube-system   po/kube-scheduler-master1                  1/1       Running   0          2h
kube-system   po/kubernetes-dashboard-3697905830-5z89q   1/1       Running   0          2h

NAMESPACE     NAME                       CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
default       svc/kubernetes             192.160.0.1      <none>          443/TCP        2h
kube-system   svc/kubernetes-dashboard   192.175.115.20   ,172.16.35.12   80:32190/TCP   2h
```

Run a simple nginx application:
```sh
$ kubectl create -f examples/nginx/
$ kubectl get svc,po -o wide
```
