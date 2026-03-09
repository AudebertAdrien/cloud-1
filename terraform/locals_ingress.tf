# === Ingress Rules === #
locals {
  ingress_rules = {
    ssh = {
      description   = "Allow SSH for remote administration"
      port          = "22"
      source_ranges = var.ssh_source_ranges
    }
    http = {
      description   = "Allow HTTP traffic"
      port          = "80"
      source_ranges = ["0.0.0.0/0"]
    }
    https = {
      description   = "Allow HTTPS traffic"
      port          = "443"
      source_ranges = ["0.0.0.0/0"]
    }
  }
}
