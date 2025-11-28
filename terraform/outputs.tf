output "namespace" {
  description = "Namespace utilisé"
  value       = kubernetes_namespace.notesapp.metadata[0].name
}

output "app_url" {
  description = "URL d'accès à l'application"
  value       = "http://notes.${var.vm_ip}.nip.io"
}

output "database_service" {
  description = "Service PostgreSQL"
  value       = kubernetes_service.postgres.metadata[0].name
}

output "api_service" {
  description = "Service API"
  value       = kubernetes_service.api.metadata[0].name
}

output "frontend_service" {
  description = "Service Frontend"
  value       = kubernetes_service.frontend.metadata[0].name
}