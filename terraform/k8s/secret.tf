resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  data = {
    POSTGRES_PASSWORD = base64encode("notepass")
  }
}
