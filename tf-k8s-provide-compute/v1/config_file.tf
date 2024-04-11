resource "local_file" "config" {
  filename = "ansible_vars.yaml"
  content = yamlencode({
    cluster_name                        = var.cluster_name
    kubeconfig_localhost                = true
    supplementary_addresses_in_ssl_keys = [yandex_vpc_address.k8s_api.external_ipv4_address[0].address]
    loadbalancer_apiserver = {
      address = yandex_vpc_address.k8s_api.external_ipv4_address[0].address
      port    = var.api_port
    }
  })
}
