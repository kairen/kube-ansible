[![pipeline status](https://gitlab.com/kairen/kube-ansible/badges/pr-80/pipeline.svg)](https://gitlab.com/kairen/kube-ansible/commits/pr-80)
# Ansible playbooks to build Kubernetes
A ansible playbooks to building the hard way Kubernetes cluster, This playbook is a fully automated command to bring up a Kubernetes cluster on VM or Baremetal.

[![asciicast](https://asciinema.org/a/YjC8qJshj47pVndOLBFRQ7iai.png)](https://asciinema.org/a/YjC8qJshj47pVndOLBFRQ7iai?speed=2)

Feature list:
- [x] Support build virtual cluster using vagrant.
- [x] Kubernetes v1.7.0+.
- [x] Kubernetes common addons.
- [x] Support CNI(calico, flannel, ..., etc) and CRI(docker, containerd).
- [x] Build HA using Keepalived and HAProxy.
- [ ] Build HA using Nginx reverse proxy.
- [x] Ingress controller.
- [x] Ceph on Kubernetes(v10.2.0+).
- [ ] Offline installation mode.

## Quick Start
In this section you will deploy a cluster using vagrant.

Prerequisites:
* *Ansible version*: v2.4 (or newer).
* [Vagrant](https://www.vagrantup.com/downloads.html): >= 1.7.0.
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads): >= 5.0.0.
* Mac OS X need to install `sshpass` tool.

```sh
$ brew install http://git.io/sshpass.rb
```

The getting started guide will use Vagrant with VirtualBox. It can deploy your Kubernetes cluster with a single command:
```sh
$ ./tools/setup -m 2048 -n calico -i eth1
Cluster Size: 1 master, 2 worker.
     VM Size: 1 vCPU, 2048 MB
     VM Info: ubuntu16, virtualbox
         CNI: calico, Binding iface: eth1
Start deploying?(y):
```
> * Check latest vagrant image box interface(default binding `enp0s8`).
> * Use libvirt provider as `sudo ./tools/setup -p libvirt -i eth1`.

The default cluster using 'RBAC', so you need add permission to access API:
```sh
$ cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: open-api
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: system:anonymous
EOF
```

Login the addon's dashboard:
- Dashboard: [https://API_SERVER:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/](https://API_SERVER:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/)
- Logging: [https://API_SERVER:6443/api/v1/proxy/namespaces/kube-system/services/kibana-logging](https://API_SERVER:6443/api/v1/proxy/namespaces/kube-system/services/kibana-logging)
- Monitor: [https://API_SERVER:6443/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana](https://API_SERVER:6443/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana)

As of release 1.7 Dashboard no longer has full admin privileges granted by default, so you need to create a token to access the resources:
```sh
$ kubectl -n kube-system create sa dashboard
$ kubectl create clusterrolebinding dashboard --clusterrole cluster-admin --serviceaccount=kube-system:dashboard
$ kubectl -n kube-system get sa dashboard -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2017-11-27T17:06:41Z
  name: dashboard
  namespace: kube-system
  resourceVersion: "69076"
  selfLink: /api/v1/namespaces/kube-system/serviceaccounts/dashboard
  uid: 56b880bf-d395-11e7-9528-448a5ba4bd34
secrets:
- name: dashboard-token-vg52j

$ kubectl -n kube-system describe secrets dashboard-token-vg52j
...
token:      eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJkYXNoYm9hcmQtdG9rZW4tdmc1MmoiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGFzaGJvYXJkIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNTZiODgwYmYtZDM5NS0xMWU3LTk1MjgtNDQ4YTViYTRiZDM0Iiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50Omt1YmUtc3lzdGVtOmRhc2hib2FyZCJ9.bVRECfNS4NDmWAFWxGbAi1n9SfQ-TMNafPtF70pbp9Kun9RbC3BNR5NjTEuKjwt8nqZ6k3r09UKJ4dpo2lHtr2RTNAfEsoEGtoMlW8X9lg70ccPB0M1KJiz3c7-gpDUaQRIMNwz42db7Q1dN7HLieD6I4lFsHgk9NPUIVKqJ0p6PNTp99pBwvpvnKX72NIiIvgRwC2cnFr3R6WdUEsuVfuWGdF-jXyc6lS7_kOiXp2yh6Ym_YYIr3SsjYK7XUIPHrBqWjF-KXO_AL3J8J_UebtWSGomYvuXXbbAUefbOK4qopqQ6FzRXQs00KrKa8sfqrKMm_x71Kyqq6RbFECsHPA
```
> Copy and paste the `token` to dashboard.

## Manual deployment
In this section you will manually deploy a cluster on your machines.

Prerequisites:
* *Ansible version: v2.4.0 (or newer)*.
* *Linux distributions*: Ubuntu 16+/CentOS 7.x.(CoreOS and SUSE coming soon)
* All Master/Node should have password-less access from `Deploy` node.

For machine example:

| IP Address      |   Role           |   CPU    |   Memory   |
|-----------------|------------------|----------|------------|
| 172.16.35.9     | vip              |    -     |     -      |
| 172.16.35.13    | master1          |    4     |     8G     |
| 172.16.35.10    | node1            |    4     |     8G     |
| 172.16.35.11    | node2            |    4     |     8G     |
| 172.16.35.12    | node3            |    4     |     8G     |

Add the machine info gathered above into a file called `inventory`. For inventory example:
```
[etcds]
172.16.35.13

[masters]
172.16.35.13

[nodes]
172.16.35.[10:12]

[kube-cluster:children]
masters
nodes

[kube-addon:children]
masters
```

Set the variables in `group_vars/all.yml` to reflect you need options. For example:
```yml
# Kubenrtes version, only support 1.7.0+.
kube_version: 1.8.4

# CRI plugin,
# Supported runtime: docker, containerd.
cri_plugin: docker

# CNI plugin,
# Supported network: flannel, calico, canal, weave or router.
network: calico
pod_network_cidr: 10.244.0.0/16

# CNI opts: flannel(--iface=enp0s8), calico(interface=enp0s8), canal(enp0s8).
cni_iface: interface=eth1

lb_vip_address: 172.16.35.9

# Extra addons
kube_dashboard: true
kube_monitoring: true
```

### Deploy a Kubernetes cluster
If everything is ready, just run `cluster.yml` to deploy cluster:
```sh
$ ansible-playbook cluster.yml
```

And then run `addons.yml` to create addons:
```sh
$ ansible-playbook addons.yml
```

### Deploy Ceph cluster on Kubernetes
If you want to deploy a Ceph cluster on to Kubernetes, just run `storage.yml`:
```sh
$ ansible-playbook storage.yml
```

When Ceph cluster is fully running, you must label your storage nodes in order to run osd pods on them:
```sh
$ kubectl label node <node_name> node-type=storage
```

### Reset cluster
You can reset cluster with the `reset.yml` playbook:
```sh
$ ansible-playbook reset.yml
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
po/ceph-mds-2743106415-gccj5         1/1       Running   0          1h        172.16.35.10  node1
po/ceph-mon-246094207-6r9g6          1/1       Running   0          1h        172.16.35.10  node1
...
```

Get ceph status using kubectl exec:
```sh
$ kubectl --namespace=ceph exec -ti ceph-mon-246094207-6r9g6 -- ceph -s

cluster bafca3e9-b361-464c-b8fa-04bf60b3189f
 health HEALTH_OK
 monmap e2: 1 mons at {ceph-mon-246094207-6r9g6=10.244.67.2:6789/0}
        election epoch 4, quorum 0 ceph-mon-246094207-6r9g6
  fsmap e5: 1/1/1 up {0=mds-ceph-mds-2743106415-gccj5=up:active}
    mgr no daemons active
 osdmap e17: 3 osds: 3 up, 3 in
        flags sortbitwise,require_jewel_osds,require_kraken_osds
  pgmap v1813: 80 pgs, 3 pools, 2148 bytes data, 20 objects
        32751 MB used, 83338 MB / 113 GB avail
              80 active+clean
```
