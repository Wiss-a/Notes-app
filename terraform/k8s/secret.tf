resource "kubernetes_secret" "notes_db" {
  metadata {
    name      = "notes-db-secret"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

 data = {
    POSTGRES_USER     = "notes"
    POSTGRES_PASSWORD = "notespass"
    POSTGRES_DB       = "notesdb"
  }

  type = "Opaque"
}
