terraform {
  required_version = ">= 1.1.0"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  config_path = ".kube/config"
  config_context = "default"
}

