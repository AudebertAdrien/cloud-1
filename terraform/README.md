# Terraform GCP Infrastructure

This Terraform configuration creates the infrastructure for deploying WordPress on Google Cloud Platform.

## What Gets Created

- **VPC Network** - Isolated network for your resources
- **Subnet** - 10.0.1.0/24 IP range
- **Firewall Rules**:
  - SSH (port 22)
  - HTTP (port 80)
  - HTTPS (port 443)
- **Static IP Address** - For consistent access
- **Compute Instance** - Ubuntu 20.04 LTS (e2-micro for free tier)

## Prerequisites

1. **GCP Account** with billing enabled
2. **GCP Project** created
3. **Terraform** installed (`terraform --version`)
4. **gcloud CLI** installed and authenticated
5. **SSH Key** generated (`~/.ssh/id_rsa.pub`)

## Setup Steps

### 1. Authenticate with GCP

```bash
gcloud auth login
gcloud auth application-default login
```

### 2. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your project ID:

```hcl
project_id = "your-actual-gcp-project-id"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 6. Get Outputs

```bash
terraform output
```

You'll see:
- `instance_ip` - IP address to access your server
- `ssh_command` - Command to SSH into the server
- `wordpress_url` - URL for your WordPress site

## Cost Optimization

- **e2-micro** instance is **free tier eligible** (1 instance per month)
- **30 GB standard persistent disk** is included in free tier
- **1 static external IP** is free when attached to a running instance

## Cleanup

To destroy all resources and avoid charges:

```bash
terraform destroy
```

Type `yes` when prompted.

## Next Steps

After Terraform completes, use Ansible to deploy WordPress:

```bash
cd ../ansible
ansible-playbook -i inventory.ini playbook.yml
```
