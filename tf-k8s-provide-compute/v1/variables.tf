variable "cluster_name" {
  type = string
}

variable "workload_on_masters" {
  type = bool
}

variable "num_masters" {
  type = number
}

variable "num_nodes" { # masters not included
  type = number
}

variable "compute_image_id" {
  type = string
}

variable "locations" {
  type = list(object({
    zone      = string
    subnet_id = string
  }))
}

variable "nodes_users" {
  type = list(object({
    name     = string
    ssh_keys = list(string)
  }))
}

variable "api_port" {
  type    = number
  default = 6443
}

variable "masters_parameters" {
  type = object({
    platform_id = string
    resources = object({
      cores         = number
      memory        = number
      core_fraction = number
    })
    boot_disk_size_gbytes = optional(number, 15)
  })
}

variable "nodes_parameters" {
  type = object({
    platform_id = string
    resources = object({
      cores         = number
      memory        = number
      core_fraction = number
    })
    boot_disk_size_gbytes = optional(number, 15)
  })
}

variable "oidc_auth_parameters" {
  type = object({
    enabled   = bool
    url       = string
    client_id = string
  })
  default = {
    enabled   = false
    url       = null
    client_id = null
  }
}

variable "supplementary_addresses_in_ssl_keys" {
  type    = list(string)
  default = []
}

variable "node_listeners" {
  type = list(object({
    name        = string
    port        = number
    target_port = number
  }))
  default = []
}
