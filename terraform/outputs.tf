output "instance_names" {
  description = "Names of instances"
  value       = google_compute_instance.main[*].name
}

output "instance_ips" {
  description = "Public IP addresses of instances"
  value       = google_compute_address.main[*].address
}

output "instance_zones" {
  description = "Zones where instances are deployed"
  value       = google_compute_instance.main[*].zone
}
