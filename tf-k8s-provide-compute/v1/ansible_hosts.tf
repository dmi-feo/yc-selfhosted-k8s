resource "local_file" "ansible_hosts" {
  filename = "ansible_hosts.yaml"
  content = templatefile(
    "${path.module}/templates/ansible_hosts.yaml.tftpl",
    {
      masters = [
        for vm in yandex_compute_instance.masters :
        { name = vm.labels[local.label_name], ip = vm.network_interface[0].ip_address }
      ]
      nodes = [
        for vm in yandex_compute_instance.nodes :
        { name = vm.labels[local.label_name], ip = vm.network_interface[0].ip_address }
      ]
      workload_on_masters = var.workload_on_masters
    }
  )
}
