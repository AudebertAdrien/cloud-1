# Cloud-1

Automated deployment of a WordPress stack on GCP using Terraform, Ansible and Docker.

The stack follows the "Inception" architecture: Nginx handles reverse proxying and TLS, WordPress runs with php-fpm, MariaDB is the database, and phpMyAdmin is available for DB management. Each service runs in its own container.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- Python 3 + a virtual environment with [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) (`pip install ansible`)
- A GCP project with billing enabled
- `gcloud` CLI authenticated (`gcloud auth application-default login`)
- GNU Make

Don't forget to activate your venv before running anything Ansible-related (`install`, `secrets-view`, `secrets-edit`).

## Getting started

### 1. Generate an SSH key

```bash
make key
```

Creates `cloud_1-key` and `cloud_1-key.pub` in the project root. Terraform uses this key to set up SSH access on the instances.

### 2. Configure Terraform variables

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with your values. At minimum you need `project_id`. You can also set `instance_count` to deploy multiple servers (defaults to 1).

### 3. Set up Ansible Vault

Database passwords and other secrets are encrypted with Ansible Vault. You need to create a `.vault_pass` file containing the vault password:

```bash
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

This file is git-ignored, so you'll have to create it on every machine. Ask your project admin for the password if you don't have it.

You can inspect or modify the secrets with:

```bash
make secrets-view
make secrets-edit
```

### 4. Provision the infrastructure

```bash
make tf-init
make tf-apply
```

This creates the VPC, firewall rules, static IPs, and compute instances on GCP. All the IPs are stored in Terraform state and picked up automatically by the other `make` targets.

### 5. Deploy the stack

```bash
make install
```

This generates the Ansible inventory from Terraform output, then runs the playbook on all instances in parallel. It will:
- Wait for the startup script to finish, then update apt
- Configure UFW (only ports 22, 80, 443 open)
- Install Docker and Docker Compose
- Generate self-signed TLS certificates
- Deploy the container stack with docker compose

Once done, the command prints the URLs for each instance.

## Accessing the services

After a successful deploy, each instance exposes:

- **WordPress** at `https://<IP>/`
- **phpMyAdmin** at `https://<IP>/phpmyadmin/`

The certificate is self-signed, so your browser will warn you. Just click through it.

To SSH into an instance:

```bash
make ssh          # connects to the first instance
make ssh N=1      # connects to the second instance
```

## Multi-server deployment

To deploy on multiple servers, set `instance_count` in your `terraform.tfvars`:

```hcl
instance_count = 3
```

Then run `make tf-apply && make install`. Terraform creates 3 instances with their own static IPs, and Ansible provisions all of them in parallel. Each instance runs an independent copy of the full WordPress stack.

## Make targets

| Target | Description |
|---|---|
| `make key` | Generate the SSH keypair |
| `make tf-init` | Initialize Terraform |
| `make tf-plan` | Preview infrastructure changes |
| `make tf-apply` | Create/update GCP resources |
| `make tf-destroy` | Tear down all GCP resources |
| `make inventory` | Generate the Ansible inventory from Terraform output |
| `make install` | Generate inventory + run the Ansible playbook |
| `make ssh` | SSH into an instance (`N=0` by default) |
| `make secrets-view` | View encrypted Ansible secrets |
| `make secrets-edit` | Edit encrypted Ansible secrets |
| `make clean_known_hosts` | Remove instance IPs from `~/.ssh/known_hosts` |
| `make clean` | Destroy everything: infra, known_hosts, SSH keys, inventory |

## Troubleshooting

If you get this after redeploying or changing IPs:

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

Just run `make clean_known_hosts` to clear the old fingerprints.