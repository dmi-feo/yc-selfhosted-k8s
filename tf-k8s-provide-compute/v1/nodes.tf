resource "yandex_compute_instance" "masters" {
  count = var.num_masters

  name        = "k8s-${var.cluster_name}-master-${count.index + 1}"
  platform_id = var.vm_parameters.platform_id
  zone        = var.locations[count.index % length(var.locations)].zone

  labels = {
    (local.label_role_master) = "1"
    (local.label_role_node)   = var.workload_on_masters ? "1" : "0"
    (local.label_name)        = "master-${count.index + 1}"
  }

  resources {
    cores         = var.vm_parameters.resources.cores
    memory        = var.vm_parameters.resources.memory
    core_fraction = var.vm_parameters.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size     = var.vm_parameters.boot_disk_size_gbytes
      image_id = var.compute_image_id
    }
  }

  network_interface {
    subnet_id = var.locations[count.index % length(var.locations)].subnet_id
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init-config.yaml.tftpl", { users = var.nodes_users })
  }
}

resource "yandex_compute_instance" "nodes" {
  count = var.num_nodes

  name        = "k8s-${var.cluster_name}-node-${count.index + 1}"
  platform_id = var.vm_parameters.platform_id
  zone        = var.locations[count.index % length(var.locations)].zone

  labels = {
    (local.label_role_master) = "0"
    (local.label_role_node)   = "1"
    (local.label_name)        = "node-${count.index + 1}"
  }

  resources {
    cores         = var.vm_parameters.resources.cores
    memory        = var.vm_parameters.resources.memory
    core_fraction = var.vm_parameters.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size     = var.vm_parameters.boot_disk_size_gbytes
      image_id = var.compute_image_id
    }
  }

  network_interface {
    subnet_id = var.locations[count.index % length(var.locations)].subnet_id
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init-config.yaml.tftpl", { users = var.nodes_users })
  }
}
