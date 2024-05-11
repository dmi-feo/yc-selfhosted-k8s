output "masters_lb_address" {
  value = yandex_vpc_address.k8s_masters.external_ipv4_address[0].address
}

output "nodes_lb_address" {
  value = yandex_vpc_address.k8s_nodes.external_ipv4_address[0].address
}
