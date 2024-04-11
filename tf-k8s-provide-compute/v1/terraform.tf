terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.112.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
  }
}
