output "lb_address" {
  value = yandex_vpc_address.k8s_api.external_ipv4_address[0].address
}
