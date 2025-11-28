resource "kubernetes_namespace" "notesapp" {
  metadata {
    name = var.namespace
  }
}
