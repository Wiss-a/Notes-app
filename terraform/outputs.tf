output "namespace" {
  description = "Namespace Kubernetes utilisé pour l'application"
  value       = kubernetes_namespace.notesapp.metadata[0].name
}

output "postgres_service" {
  description = "Nom du service PostgreSQL"
  value       = kubernetes_service.postgres.metadata[0].name
}

output "api_service" {
  description = "Nom du service API"
  value       = kubernetes_service.api.metadata[0].name
}

output "frontend_service" {
  description = "Nom du service Frontend"
  value       = kubernetes_service.frontend.metadata[0].name
}

output "ingress_hostname" {
  description = "Adresse d'accès à l'application via Ingress"
  value       = kubernetes_ingress.notes_ingress.spec[0].rule[0].host
}

output "access_url" {
  description = "URL complète pour accéder à l'application"
  value       = "http://${kubernetes_ingress.notes_ingress.spec[0].rule[0].host}"
}
