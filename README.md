# My Kubernetes and Ceph development environment
A vagrant development environment for Kubernetes and Ceph

If you want use this vagrant files, you must install the following of plugins:
```sh
$ vagrant plugin install vagrant-hostsupdater \
                         vagrant-libvirt
                         vagrant-openstack-provider
```

Then, you must install ansible in your host:
```sh
$ sudo apt-get install -y software-properties-common
$ sudo apt-add-repository -y ppa:ansible/ansible
$ sudo apt-get update && sudo apt-get install -y ansible
```

Run a simple nginx application:
```sh
$ kubectl run nginx --image=nginx --replicas=2 --port=80
$ kubectl expose deploy nginx --port=80 --type=NodePort
$ kubectl get svc,po -o wide
```
