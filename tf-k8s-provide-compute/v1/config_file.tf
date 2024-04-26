resource "local_file" "config" {
  filename = "ansible_vars.yaml"
  content = yamlencode(merge(
    {
      cluster_name                        = var.cluster_name
      kubeconfig_localhost                = true
      supplementary_addresses_in_ssl_keys = [yandex_vpc_address.k8s_api.external_ipv4_address[0].address]
      loadbalancer_apiserver = {
        address = yandex_vpc_address.k8s_api.external_ipv4_address[0].address
        port    = var.api_port
      }
    },
    var.oidc_auth_parameters.enabled ? {
      kube_oidc_auth            = true
      kube_oidc_url             = var.oidc_auth_parameters.url
      kube_oidc_client_id       = var.oidc_auth_parameters.client_id
    } : {},
  ))
}
