variable "namespace" {
  description = "Kubernetes namespace for the NotesApp"
  default     = "notesapp"
}
resource "kubernetes_namespace" "notesapp" {
  metadata {
    name = var.namespace
  }
}
