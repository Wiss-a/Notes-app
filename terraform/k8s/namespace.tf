variable "namespace" {
  description = "Kubernetes namespace for the NotesApp"
  default     = "notesapp"
}
resource "kubernetes_namespace" "notes" {
  metadata {
    name = var.namespace
  }
}
