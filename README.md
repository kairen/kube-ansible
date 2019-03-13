[![Build Status](https://travis-ci.org/kairen/kube-ansible.svg?branch=master)](https://travis-ci.org/kairen/kube-ansible)
# Kubernetes Ansible
A collection of playbooks for deploying/managing/upgrading a Kubernetes cluster onto machines, they are fully automated command to bring up a Kubernetes cluster on bare-metal or VMs.

[![asciicast](https://asciinema.org/a/fDjMx3fTZX9SZktqEdTtWwZwi.png)](https://asciinema.org/a/fDjMx3fTZX9SZktqEdTtWwZwi?speed=2)

Feature list:
- [x] Support Kubernetes v1.10.0+.
- [x] Highly available Kubernetes cluster.
- [x] Full of the binaries installation.
- [x] Kubernetes addons:
  - [x] Promethues Monitoring.
  - [x] EFK Logging.
  - [x] Metrics Server.
  - [x] NGINX Ingress Controller.
  - [x] Kubernetes Dashboard.
- [x] Support container network:
  - [x] Calico.
  - [x] Flannel.
- [x] Support container runtime:
  - [x] Docker.
  - [x] NVIDIA-Docker.(Require NVIDIA driver and CUDA 9.0+)
  - [x] Containerd.
  - [ ] CRI-O.

## Quick Start
In this section you will deploy a cluster via vagrant.

Prerequisites:
* Ansible version: *v2.5 (or newer)*.
* [Vagrant](https://www.vagrantup.com/downloads.html): >= 2.0.0.
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads): >= 5.0.0.
* Mac OS X need to install `sshpass` tool.

```sh
$ brew install http://git.io/sshpass.rb
```

The getting started guide will use Vagrant with VirtualBox to deploy a Kubernetes cluster onto virtual machines. You can deploy the cluster with a single command:
```sh
$ ./hack/setup-vms
Cluster Size: 1 master, 2 worker.
  VM Size: 1 vCPU, 2048 MB
  VM Info: ubuntu16, virtualbox
  CNI binding iface: eth1
Start to deploy?(y):
```
> * You also can use `sudo ./hack/setup-vms -p libvirt -i eth1` command to deploy the cluster onto KVM.

If you want to access API you need to create RBAC object define the permission of role. For example using `cluster-admin` role:
```sh
$ kubectl create clusterrolebinding open-api --clusterrole=cluster-admin --user=system:anonymous
```

Login the addon's dashboard:
- Dashboard: [https://API_SERVER:8443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/](https://API_SERVER:8443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/)
- Logging: [https://API_SERVER:8443/api/v1/namespaces/kube-system/services/kibana-logging/proxy/](https://API_SERVER:8443/api/v1/namespaces/kube-system/services/kibana-logging/proxy/)

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
* Ansible version: *v2.5 (or newer)*.
* *Linux distributions*: Ubuntu 16+/Debian/CentOS 7.x.
* All Master/Node should have password-less access from `deploy` node.

For machine example:

| IP Address      |   Role           |   CPU    |   Memory   |
|-----------------|------------------|----------|------------|
| 172.16.35.9     | vip              |    -     |     -      |
| 172.16.35.10    | k8s-m1           |    4     |     8G     |
| 172.16.35.11    | k8s-n1           |    4     |     8G     |
| 172.16.35.12    | k8s-n2           |    4     |     8G     |
| 172.16.35.13    | k8s-n3           |    4     |     8G     |

Add the machine info gathered above into a file called `inventory/hosts.ini`. For inventory example:
```
[etcds]
k8s-m1
k8s-n[1:2]

[masters]
k8s-m1
k8s-n1

[nodes]
k8s-n[1:3]

[kube-cluster:children]
masters
nodes
```

Set the variables in `group_vars/all.yml` to reflect you need options. For example:
```yml
# overide kubernetes version(default: 1.10.6)
kube_version: 1.11.2

# container runtime, supported: docker, nvidia-docker, containerd.
container_runtime: docker

# container network, supported: calico, flannel.
cni_enable: true
container_network: calico
cni_iface: ''

# highly available variables
vip_interface: ''
vip_address: 172.16.35.9

# etcd variables
etcd_iface: ''

# kubernetes extra addons variables
enable_dashboard: true
enable_logging: false
enable_monitoring: false
enable_ingress: false
enable_metric_server: true

# monitoring grafana user/password
monitoring_grafana_user: "admin"
monitoring_grafana_password: "p@ssw0rd"
```

### Deploy a Kubernetes cluster
If everything is ready, just run `cluster.yml` playbook to deploy the cluster:
```sh
$ ansible-playbook -i inventory/hosts.ini cluster.yml
```

And then run `addons.yml` to create addons:
```sh
$ ansible-playbook -i inventory/hosts.ini addons.yml
```

## Verify cluster
Verify that you have deployed the cluster, check the cluster as following commands:
```sh
$ kubectl -n kube-system get po,svc

NAME                                 READY     STATUS    RESTARTS   AGE       IP             NODE
po/haproxy-master1                   1/1       Running   0          2h        172.16.35.10   k8s-m1
...
```

### Reset cluster
Finally, if you want to clean the cluster and redeploy, you can reset the cluster by `reset-cluster.yml` playbook.:
```sh
$ ansible-playbook -i inventory/hosts.ini reset-cluster.yml
```

## Contributing
Pull requests are always welcome!!! I am always thrilled to receive pull requests.
