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
    config_path = "../ansible/config"
    config_context = "default"
  }

}
provider "kubernetes" {
  config_path = "../ansible/config"
  config_context = "default"
}
resource "kubernetes_namespace_v1" "kiratech-test-namespace" {
  metadata {


    name = "kiratech-test"
  }
}
resource "helm_release" "kubetail" {
  name  = "kubetail"
  chart = "../helm/kubetail"
  namespace = "kiratech-test"
}

resource "kubernetes_manifest" "kube-bench" {
  manifest = yamldecode(file("bench.yaml"))
}
resource "kubernetes_manifest" "kubetail-nodeport" {
  manifest = yamldecode(file("kubetail_nodeport.yaml"))
}