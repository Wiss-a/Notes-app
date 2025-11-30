resource "kubernetes_config_map" "metallb_config" {
  metadata {
    name      = "notes-metallb"
    namespace = kubernetes_namespace.notesapp.metadata[0].name
  }

  data = {
    config =
      address-pools:
      - name: default
        protocol: layer2
        addresses:
        - 192.168.49.100-192.168.49.110
    
  }
}