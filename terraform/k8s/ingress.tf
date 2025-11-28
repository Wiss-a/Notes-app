resource "kubernetes_ingress" "notes_ingress" {
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
        path {
          path = "/"
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
