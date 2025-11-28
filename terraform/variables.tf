variable "namespace" {
  description = "Namespace Kubernetes pour l'application"
  type        = string
  default     = "notesapp"
}

variable "vm_ip" {
  description = "Adresse IP de la VM pour nip.io"
  type        = string
}