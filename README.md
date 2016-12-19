# My Development environment vagrant
A vagrant development environment for Kyle.Bai

If you want use this vagrant files, you will need install the following of plugins:
```sh
$ vagrant plugin install vagrant-hostsupdater vagrant-libvirt
```

Then, you must install ansible on Host:
```sh
$ sudo apt-get install -y software-properties-common
$ sudo apt-add-repository -y ppa:ansible/ansible
$ sudo apt-get update && sudo apt-get install -y ansible
```

## TODO List
- [ ] Kubernetes ansible playbooks
- [ ] Ceph ansible playbooks
- [ ] Kubernetes integrate with Ceph playbooks
