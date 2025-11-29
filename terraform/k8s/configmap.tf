resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "notes-config"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  data = {
    POSTGRES_DB   = "notesdb"
    POSTGRES_USER = "notes"
    POSTGRES_PASSWORD = "notespass"
  }
}
