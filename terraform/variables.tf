variable "instance_count" {
  description = "Number of instances to deploy"
  type        = number
  default     = 1
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloud-1-wordpress"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "e2-micro"
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "../cloud_1-key.pub"
}


variable "service_account_email" {
  description = "Service account email (leave empty for default)"
  type        = string
  default     = ""
}

variable "ssh_source_ranges" {
  description = "IP ranges allowed for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "subnet_cidr" {
  description = "CIDR range for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Changed to ubuntu 22.04 because subject mentions an old version which is non existant.
variable "boot_image" {
  description = "Boot disk image"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-standard"
}
