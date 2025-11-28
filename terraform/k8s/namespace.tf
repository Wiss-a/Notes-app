resource "kubernetes_namespace" "notes" {
  metadata {
    name = var.namespace
  }
}
