# Cloud-1 ☁️

Automated deployment of a secure WordPress infrastructure on a remote cloud server (GCP/AWS) using Ansible and Docker.

The deployment follows the "Inception" architecture:

- Nginx (Reverse Proxy & TLS)
- WordPress + MariaDB
- Self-signed TLS Certificates

## 📋 Prerequisites

Before starting, ensure you have:

- Ansible and Make installed on your local machine.
- A running Cloud Instance (Debian 12 or Ubuntu 20.04+).
- Inbound Ports allowed on your cloud provider firewall:
  - 22 (SSH)
  - 80 (HTTP)
  - 443 (HTTPS)

## 🚀 Quick Start

### 1. Configuration

Open the Makefile at the root of the project and edit the top variable with your instance IP:

```
HOST_IP = 34.155.XXX.XXX    # Replace with your Instance Public IP
```

### 2. Inventory Setup

Update the Ansible inventory file with your instance IP address.

Open `inventory.yml` and replace the IP address in the `ansible_host` field:

```yaml
  ansible_host: YOUR_INSTANCE_IP  # Replace with your Cloud Instance Public IP
```

Example:

```yaml
ansible_host: 34.163.40.64
```

### 3. SSH Key Setup

You need to generate a dedicated SSH key for this project and upload the public part to your cloud provider for secure authentication.

#### A. Generate the key:

```bash
make key
```

This will create `cloud_1-key` (private) and `cloud_1-key.pub` (public).

#### B. Authorize the key:

Copy the content of the public key:

```bash
cat cloud_1-key.pub
```

Go to your Cloud Provider (GCP) and add this key to your instance.

### 4. Secrets Management (Ansible Vault) 🔐

This project uses Ansible Vault to encrypt sensitive data (passwords, API keys).

#### A. Setup the Vault Password:

1. Ask the project administrator for the Vault Password.
2. Create a file named `.vault_pass` at the root of the project.
3. Paste the password inside (no spaces, no new lines).

#### B. Edit Secrets (Optional):

If you have the correct `.vault_pass` file, you can view or edit the encrypted variables:

```bash
make secrets-edit
```

### 5. Deployment

Once configuration is done, launch the automated installation:

```bash
make install
```

Ansible will automatically:

- Configure the server and install Docker.
- Set up the firewall (UFW).
- Generate self-signed TLS certificates.
- Start the container stack.

## 🌐 Access

### Web Access

Open your browser and navigate to:

```
https://<YOUR_HOST_IP>
```

**Note:** Since the SSL certificate is self-signed, your browser will display a security alert. This is expected. Click **Advanced → Proceed** (or "Accept Risk") to access the site.

### Server Access

To connect to your server via SSH using the project key:

```bash
make ssh
```

## 🛠️ Troubleshooting & Utilities

**SSH Connection Issues:**

If you reboot your instance (IP change) or regenerate your keys, you might encounter a "Remote Host Identification Changed" error due to a host fingerprint mismatch.

Run this command to clean your local `known_hosts` file for this specific IP:

```bash
make clean_known_hosts
```
