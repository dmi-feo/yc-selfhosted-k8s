resource "yandex_vpc_address" "k8s_masters" {
  name = "k8s-${var.cluster_name}-masters"

  external_ipv4_address {
    zone_id = var.locations[0].zone
  }
}

resource "yandex_vpc_address" "k8s_nodes" {
  name = "k8s-${var.cluster_name}-nodes"

  external_ipv4_address {
    zone_id = var.locations[0].zone
  }
}

resource "yandex_lb_target_group" "k8s_masters" {
  name = "k8s-${var.cluster_name}-masters"

  dynamic "target" {
    for_each = yandex_compute_instance.masters
    content {
      subnet_id = one(target.value.network_interface).subnet_id
      address   = one(target.value.network_interface).ip_address
    }
  }
}

resource "yandex_lb_target_group" "k8s_nodes" {
  name = "k8s-${var.cluster_name}-nodes"

  dynamic "target" {
    for_each = yandex_compute_instance.nodes
    content {
      subnet_id = one(target.value.network_interface).subnet_id
      address   = one(target.value.network_interface).ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "k8s_masters" {
  name = "k8s-${var.cluster_name}-masters"

  listener {
    name        = "k8s-api"
    port        = var.api_port
    target_port = 6443
    external_address_spec {
      address = yandex_vpc_address.k8s_masters.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.k8s_masters.id

    healthcheck {
      name = "k8s-api-alive"
      tcp_options {
        port = 6443
      }
    }
  }
}

resource "yandex_lb_network_load_balancer" "k8s_all_nodes" {
  name = "k8s-${var.cluster_name}-all-nodes"

  dynamic "listener" {
    for_each = var.node_listeners
    content {
      name        = listener.value.name
      port        = listener.value.port
      target_port = listener.value.target_port
      external_address_spec {
        address = yandex_vpc_address.k8s_nodes.external_ipv4_address[0].address
      }
    }
  }

  dynamic "attached_target_group" {
    for_each = compact([
      yandex_lb_target_group.k8s_nodes.id,
      var.workload_on_masters ? yandex_lb_target_group.k8s_masters.id : null,
    ])
    content {
      target_group_id = attached_target_group.value

      healthcheck {
        name = "node-ssh-alive"
        tcp_options {
          port = 22
        }
      }
    }
  }
}
