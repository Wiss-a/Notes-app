terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# ===========================================
# NAMESPACE
# ===========================================
resource "kubernetes_namespace" "notesapp" {
  metadata {
    name = var.namespace
  }
}

# ===========================================
# SECRET DATABASE
# ===========================================
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  data = {
    POSTGRES_USER     = "notes"
    POSTGRES_PASSWORD = "notespass"
    POSTGRES_DB       = "notesdb"
  }
}

# ===========================================
# POSTGRESQL STATEFULSET
# ===========================================
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "notes-db"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    service_name = "notes-db"
    replicas     = 1

    selector {
      match_labels = {
        app = "notes-db"
      }
    }

    template {
      metadata {
        labels = {
          app = "notes-db"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15-alpine"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "POSTGRES_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "POSTGRES_DB"
              }
            }
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "postgres-storage"
      }

      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "2Gi"
          }
        }
      }
    }
  }
}

# ===========================================
# POSTGRESQL SERVICE
# ===========================================
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "notes-db"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-db"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}

# ===========================================
# API DEPLOYMENT
# ===========================================
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
          name              = "api"
          image             = "notes-api:1.0"
          image_pull_policy = "Never"

          port {
            container_port = 5000
          }

          env {
            name  = "DATABASE_URL"
            value = "postgresql://notes:notespass@notes-db:5432/notesdb"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_stateful_set.postgres]
}

# ===========================================
# API SERVICE
# ===========================================
resource "kubernetes_service" "api" {
  metadata {
    name      = "notes-api"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-api"
    }

    port {
      port        = 5000
      target_port = 5000
    }

    type = "ClusterIP"
  }
}

# ===========================================
# FRONTEND DEPLOYMENT
# ===========================================
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "notes-frontend"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    replicas = 2

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
          name              = "frontend"
          image             = "notes-frontend:1.0"
          image_pull_policy = "Never"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.api]
}

# ===========================================
# FRONTEND SERVICE
# ===========================================
resource "kubernetes_service" "frontend" {
  metadata {
    name      = "notes-frontend"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  spec {
    selector = {
      app = "notes-frontend"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# ===========================================
# INGRESS
# ===========================================
resource "kubernetes_ingress_v1" "notesapp" {
  metadata {
    name      = "notesapp-ingress"
    namespace = kubernetes_namespace.notesapp.metadata[0].name

    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "notes.${var.vm_ip}.nip.io"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.frontend]
}