resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "notes-frontend"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "notes-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-frontend"
        }
      }

      spec {
        container {
          name  = "notes-frontend"
          image = "notes-frontend:latest"
          image_pull_policy = "Never"


          port {
            container_port = 80
          }
        }
      }
    }
  }
}
