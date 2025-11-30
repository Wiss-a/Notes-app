resource "kubernetes_config_map" "metallb_config" {
  metadata {
    name      = "config"
    namespace = "metallb-system" 
  }

  data = {
    config = <<-EOT
      address-pools:
      - name: default
        protocol: layer2
        addresses:
        - 192.168.49.100-192.168.49.110
    EOT
  }
}