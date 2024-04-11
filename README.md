## How to create a k8s cluster over compute nodes: N simple steps.

Assuming you already have cloud + folder + vpc + virtual machine with external ip address (aka dev-vm)

Tested in Nebius Israel; however must be 100% compatible with Yandex Cloud.

1. Apply terraform module `tf-k8s-provide-compute`
2. `cd ./kubespray`
3. `cp -rfp ./inventory/sample ./inventory/my-cluster`
4. Run:
```commandline
ansible-playbook -i <path_to_your_terraform_with_module_from_p1>/ansible_hosts.yaml \
-u <username> \
--ssh-extra-args '-o ProxyCommand="ssh -W %h:%p <dev-vm>"' \
-b -v  ./cluster.yml \
--extra-vars "@<path_to_your_terraform_with_module_from_p1>/ansible_vars.yaml"
```
5. kubeconfig file will be saved here: `<path_to_your_terraform_with_module_from_p1>/artifacts/admin.conf`
6. (optional) install nfs-based persisten volume support + nfs server via terraform module `tf-k8s-pv-over-nfs`