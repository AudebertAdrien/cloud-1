output "instance_name" {
  description = "Name of instance"
  value       = google_compute_instance.main.name
}

output "instance_ip" {
  description = "Public IP address of instance"
  value       = google_compute_address.main.address
}

output "instance_zone" {
  description = "Zone where instance is deployed"
  value       = google_compute_instance.main.zone
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh ${var.ssh_user}@${google_compute_address.main.address}"
}

output "wordpress_url" {
  description = "WordPress site URL"
  value       = "https://${google_compute_address.main.address}"
}
