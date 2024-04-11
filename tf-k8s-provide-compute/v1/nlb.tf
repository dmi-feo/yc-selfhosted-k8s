resource "yandex_vpc_address" "k8s_api" {
  name      = "k8s-${var.cluster_name}-api"

  external_ipv4_address {
    zone_id = var.locations[0].zone
  }
}

resource "yandex_lb_target_group" "k8s_api" {
  name      = "k8s-${var.cluster_name}-api"

    dynamic "target" {
      for_each = yandex_compute_instance.masters
      content {
        subnet_id = one(target.value.network_interface).subnet_id
        address   = one(target.value.network_interface).ip_address
      }
    }
}

resource "yandex_lb_network_load_balancer" "k8s_api" {
  name      = "k8s-${var.cluster_name}-api"

  listener {
    name        = "k8s-api"
    port        = var.api_port
    target_port = 6443
    external_address_spec {
      address = yandex_vpc_address.k8s_api.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_api.id

    healthcheck {
      name = "k8s-api-alive"
      tcp_options {
        port = 6443
      }
    }
  }
}
