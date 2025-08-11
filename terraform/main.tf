terraform {
  required_version = ">= 1.1.0"
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.38.0"
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
provider "kubernetes" {
  config_path = ".kube/config"
  config_context = "default"
}
resource "kubernetes_namespace_v1" "example" {
  metadata {


    name = "kiratech-test"
  }
}
resource "helm_release" "kubetail" {
  name  = "kubetail"
  chart = "../helm/kubetail"
}

resource "kubernetes_manifest" "test-configmap" {
  manifest = yamldecode(file("bench.yaml"))
}
resource "kubernetes_manifest" "test-srvc" {
  manifest = yamldecode(file("kubetail_nodeport.yaml"))
}