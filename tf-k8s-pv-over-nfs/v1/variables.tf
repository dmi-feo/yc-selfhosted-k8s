variable "make_default_pv_class" {
  type = bool
}

variable "nfs_vm_parameters" {
  type = object({
    name        = optional(string, "k8s-pv-nfs-server")
    platform_id = string
    subnet_id   = string
    zone        = string
    users = list(object({
      name     = string
      ssh_keys = list(string)
    }))
    resources = object({
      cores         = number
      memory        = number
      core_fraction = number
    })
    boot_disk_size_gbytes = optional(number, 10)
    boot_disk_image_id    = string
  })
}

variable "disk_parameters" {
  type = object({
    name        = optional(string, "k8s-persistent-volumes")
    zone        = string
    size_gbytes = number
    type        = string
  })
}

variable "nfs_allowed_from" {
  type    = string
  default = "*" // or netmask
}

variable "namespace_for_charts" {
  type    = string
  default = "kube-system"
}
