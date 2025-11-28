variable "namespace" {
  description = "Namespace Kubernetes pour l'application"
  type        = string
  default     = "notesapp"
}

variable "vm_ip" {
  description = "Adresse IP de la VM pour nip.io"
  type        = string
}
variable "minikube_ip" {
  description = "IP address of Minikube"
  type        = string
}
variable "ingress_host" {
  description = "Host for the ingress resource"
  type        = string
  default     = "notes.${var.minikube_ip}.nip.io"
}