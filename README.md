# Cloud-1 ☁️

Automated deployment of a secure WordPress infrastructure on a remote cloud server using **Ansible** and **Docker**.

---

## 📋 Prerequisites

Before starting, ensure you have:

* **Ansible** and **Make** installed on your local machine
* A running **Cloud Instance**:

  * Debian 12 **or**
  * Ubuntu 20.04+
* Inbound ports allowed on your cloud firewall:

  * `22` (SSH)
  * `80` (HTTP)
  * `443` (HTTPS)

---

## 🚀 Quick Start

### 1. Configuration

Open the `Makefile` at the root of the project and edit the top variables with your instance details:

```makefile
HOST_IP = 34.155.XXX.XXX    # Your Instance Public IP
```

---

### 2. SSH Key Setup

Generate a dedicated SSH key for this project and authorize it on your server.

#### A. Generate the key

```bash
make key
```

This will create:

* `cloud_1-key` (private key)
* `cloud_1-key.pub` (public key)

#### B. Authorize the key

1. Copy the content of `cloud_1-key.pub`
2. Go to your Cloud Provider Console **GCP Metadata**
3. Add the public key to your instance

---

### 3. Deployment

Launch the automated installation:

```bash
make install
```

Ansible will:

* Configure the server
* Set up security (**UFW**)
* Generate TLS certificates
* Start the Docker containers

---

## 🌐 Access

### Web Access

Open your browser and navigate to:

```
https://<YOUR_HOST_IP>
```

⚠️ **Note**
You will see a security warning because the TLS certificate is **self-signed**.
This is expected. Click **Advanced → Proceed** to access the site.

---

### Server Access

To connect to your server via SSH using the generated key:

```bash
make ssh
```

---

## 🛠️ Utilities

If you reboot your instance and the IP address changes:

1. Update `HOST_IP` in the `Makefile`
2. Run the following command to fix SSH connection errors:

```bash
make clean_known_hosts
```

---
