resource "yandex_compute_disk" "pv_storage" {
  name = var.disk_parameters.name
  type = var.disk_parameters.type
  zone = var.disk_parameters.zone
  size = var.disk_parameters.size_gbytes
}

resource "yandex_compute_instance" "nfs" {
  name        = var.nfs_vm_parameters.name
  platform_id = var.nfs_vm_parameters.platform_id
  zone        = var.nfs_vm_parameters.zone

  allow_stopping_for_update = true

  resources {
    cores         = var.nfs_vm_parameters.resources.cores
    memory        = var.nfs_vm_parameters.resources.memory
    core_fraction = var.nfs_vm_parameters.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      size     = var.nfs_vm_parameters.boot_disk_size_gbytes
      image_id = var.nfs_vm_parameters.boot_disk_image_id
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.pv_storage.id
    device_name = local.nfs_disk_device_name
    mode        = "READ_WRITE"
  }

  network_interface {
    subnet_id = var.nfs_vm_parameters.subnet_id
  }

  metadata = {
    user-data = templatefile(
      "${path.module}/vm_metadata_userdata.yaml.tftpl",
      {
        users                = var.nfs_vm_parameters.users
        nfs_disk_device_name = local.nfs_disk_device_name
        nfs_disk_mount_path  = local.nfs_disk_mount_path
        nfs_allowed_from     = var.nfs_allowed_from
      }
    )
  }
}
