# === Main Infrastructure code for provisionning of resources === #

# NETWORKING
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  description             = "VPC for ${var.project_name} workloads"
}

resource "google_compute_subnetwork" "main" {
  name                     = "${var.project_name}-subnet"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true
}

# FIREWALL RULES
resource "google_compute_firewall" "ingress" {
  for_each = local.ingress_rules

  name        = "${var.project_name}-allow-${each.key}"
  network     = google_compute_network.main.name
  description = each.value.description
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = [each.value.port]
  }

  source_ranges = each.value.source_ranges
  target_tags   = ["${var.project_name}-server"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# COMPUTE
resource "google_compute_address" "main" {
  count       = var.instance_count
  name        = "${var.project_name}-ip-${count.index}"
  description = "Static IP for ${var.project_name} instance ${count.index}"
}

resource "google_compute_instance" "main" {
  count        = var.instance_count
  name         = "${var.project_name}-instance-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  tags   = ["${var.project_name}-server"]
  labels = local.common_labels

  boot_disk {
    initialize_params {
      image  = var.boot_image
      size   = var.disk_size_gb
      type   = var.disk_type
      labels = local.common_labels
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.main.id

    access_config {
      nat_ip = google_compute_address.main[count.index].address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    set -euo pipefail

    exec > >(tee /var/log/startup-script.log) 2>&1
    echo "Starting provisioning at $(date)"

    apt-get update -qq
    apt-get install -y -qq python3 python3-pip

    echo "Provisioning complete at $(date)"
  SCRIPT

  service_account {
    scopes = ["cloud-platform"]
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [metadata_startup_script]
  }

  depends_on = [
    google_compute_firewall.ingress
  ]
}
