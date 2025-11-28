resource "kubernetes_ingress" "notes_ingress" {
  metadata {
    name      = "notes-ingress"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    rule {
      host = "notes.${var.minikube_ip}.nip.io"

      http {
        path {
          path     = "/"
          backend {
            service_name = "notes-frontend"
            service_port = 80
          }
        }
      }
    }
  }
}
