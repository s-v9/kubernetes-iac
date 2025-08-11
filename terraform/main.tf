terraform {
  required_version = ">= 1.1.0"
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "helm" {
  # Configuration options
  kubernetes = {
    config_path = ".kube/config"
    config_context = "default"
  }

}
resource "helm_release" "kubetail" {
  name  = "kubetail"
  chart = "../helm/kubetail"
}
