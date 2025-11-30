resource "kubernetes_ingress_v1" "notes_ingress" {
  metadata {
    name      = "notes-ingress"
    namespace = kubernetes_namespace.notesapp.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }

  spec {
    rule {
      host = "notes.${var.minikube_ip}.nip.io"

      http {
        # FRONTEND
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

        # BACKEND (regex)
        path {
          path      = "/api(/|$)(.*)"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "notes-api"
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}
