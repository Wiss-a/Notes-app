resource "kubernetes_deployment" "api" {
  metadata {
    name      = "notes-api"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "notes-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-api"
        }
      }

      spec {
        container {
          name  = "notes-api"
          image = "notes-api:latest"
          image_pull_policy = "Never"

          port {
            container_port = 5000
          }

          env {
            name = "DATABASE_URL"
            value = "postgresql://notes:notepass@notes-db:5432/notesdb"
          }
        }
      }
    }
  }
}
