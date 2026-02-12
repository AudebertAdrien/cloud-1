# Cloud-1

Automated deployment of a WordPress stack on GCP using Terraform, Ansible and Docker.

The stack runs the "Inception" architecture: Nginx as a reverse proxy with TLS termination, WordPress (php-fpm), MariaDB, and phpMyAdmin — each in its own container.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- Python 3 with a virtual environment (Ansible runs inside it)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) installed (`pip install ansible`)
- A GCP project with billing enabled
- `gcloud` CLI authenticated (`gcloud auth application-default login`)
- GNU Make

> **Note:** Make sure your virtual environment is activated before running any `make` target that uses Ansible (`install`, `secrets-view`, `secrets-edit`).

## Quick Start

### 1. Generate an SSH key

```bash
make key
```

This creates `cloud_1-key` (private) and `cloud_1-key.pub` (public) in the project root. Terraform will automatically provision this key on the instance.

### 2. Configure Terraform variables

Copy the example and fill in your GCP project ID:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with your values. At minimum you need `project_id`.

### 3. Set up Ansible Vault

This project encrypts sensitive data (database passwords) with Ansible Vault.

1. Get the vault password from your project administrator.
2. Create a `.vault_pass` file at the project root containing only the password:

```bash
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

This file is git-ignored and must be created manually on each machine.

To view or edit the encrypted secrets:

```bash
make secrets-view
make secrets-edit
```

### 4. Provision the infrastructure

```bash
make tf-init      # Initialize Terraform providers
make tf-apply     # Create the GCP instance, network, firewall rules
```

After `terraform apply` completes, the instance IP is stored in the Terraform state. All subsequent `make` commands (`install`, `ssh`, etc.) automatically read it from there — no manual copy-pasting needed.

### 5. Deploy the stack

```bash
make install
```

This runs the Ansible playbook which will:
- Update the system and install dependencies
- Configure the firewall (UFW) — only ports 22, 80, 443 open
- Install Docker
- Generate self-signed TLS certificates
- Deploy and start the container stack

## Access

### WordPress

```
https://<INSTANCE_IP>
```

The certificate is self-signed, so your browser will show a security warning. Click **Advanced > Proceed** to continue.

### phpMyAdmin

```
https://<INSTANCE_IP>/phpmyadmin/
```

### SSH

```bash
make ssh
```

## Available Make targets

| Target | Description |
|---|---|
| `make key` | Generate the SSH keypair |
| `make tf-init` | Initialize Terraform |
| `make tf-plan` | Preview infrastructure changes |
| `make tf-apply` | Apply infrastructure changes |
| `make tf-destroy` | Tear down all GCP resources |
| `make install` | Run the Ansible playbook |
| `make ssh` | SSH into the instance |
| `make secrets-view` | View encrypted Ansible secrets |
| `make secrets-edit` | Edit encrypted Ansible secrets |
| `make clean_known_hosts` | Remove the instance IP from `~/.ssh/known_hosts` |
| `make clean` | Destroy infrastructure, clean known_hosts, and remove SSH keys |

## Troubleshooting

If you see this after redeploying or changing IPs:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

Run:

```bash
make clean_known_hosts
```

This removes the old fingerprint from your local `known_hosts` so SSH can connect again.
