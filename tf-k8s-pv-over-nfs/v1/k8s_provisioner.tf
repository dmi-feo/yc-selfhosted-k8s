resource "helm_release" "nfs_driver" {
  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart      = "csi-driver-nfs"
  name       = "csi-driver-nfs"
  version    = "v4.6.0"

  namespace = var.namespace_for_charts
}

resource "time_sleep" "wait_for_cloud_init" {
  depends_on      = [yandex_compute_instance.nfs]
  create_duration = "90s"

  lifecycle {
    replace_triggered_by = [yandex_compute_instance.nfs]
  }
}

resource "helm_release" "nfs_provisioner" {
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"
  chart      = "nfs-subdir-external-provisioner"
  name       = "nfs-subdir-external-provisioner"
  version    = "4.0.2"

  namespace = var.namespace_for_charts

  set {
    name  = "nfs.server"
    value = yandex_compute_instance.nfs.network_interface[0].ip_address
  }

  set {
    name  = "nfs.path"
    value = local.nfs_disk_mount_path
  }

  set {
    name  = "storageClass.defaultClass"
    value = var.make_default_pv_class
  }

  depends_on = [time_sleep.wait_for_cloud_init]
}
