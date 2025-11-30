resource "kubernetes_ingress_v1" "notes_ingress" {
  metadata {
    name      = "notes-ingress"
    namespace = kubernetes_namespace.notesapp.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    rule {
      host = "notes.${var.minikube_ip}.nip.io"

      http {
        # ---------------------------
        # FRONTEND ROUTE (/)
        # ---------------------------
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

        # ---------------------------
        # BACKEND ROUTE (/api/*)
        # ---------------------------
        path {
          path      = "/api(/|$)(.*)"
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
      }
    }
  }
}
