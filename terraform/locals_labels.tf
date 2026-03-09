# === Custom Label because why not === #
locals {
  common_labels = {
    project    = var.project_name
    managed_by = "terraform"
  }
}
