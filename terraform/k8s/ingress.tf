resource "kubernetes_ingress_v1" "notes_ingress" {
  metadata {
    name      = "notes-ingress"
    namespace = kubernetes_namespace.notesapp.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "notes.${var.minikube_ip}.nip.io"

      http {
        # BACKEND - DOIT ÊTRE EN PREMIER (plus spécifique)
        path {
          path      = "/api"
          path_type = "Prefix"

          backend {
            service {
              name = "notes-api"
              port {
                number = 5000
              }
            }
          }
        }

        # FRONTEND - EN DERNIER (catch-all)
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "notes-frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}