SECRETS_DRAFT := secrets.template.yml
SECRETS_FINAL := roles/cloud_1/vars/main.yml
VAULT_PASS := .vault_pass

SSH_USER := cloud_1-user

INVENTORY := inventory
PLAYBOOK := provisioning.yml
KEY_FILE := cloud_1-key
TF_DIR := terraform

N := 0

.PHONY: key tf-init tf-plan tf-apply tf-destroy inventory install ssh clean_known_hosts secrets-view secrets-edit clean

# === SSH Key === #
key:
	@echo "Generating SSH key for user $(SSH_USER)..."
	ssh-keygen -t ed25519 -f $(KEY_FILE) -C "$(SSH_USER)" -N ""
	chmod 600 $(KEY_FILE)
	@echo "Key generated!"

# === Terraform === #
tf-init:
	terraform -chdir=$(TF_DIR) init

tf-plan:
	terraform -chdir=$(TF_DIR) plan

tf-apply:
	terraform -chdir=$(TF_DIR) apply

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy

# === Inventory === #
inventory:
	@IPS=$$(terraform -chdir=$(TF_DIR) output -json instance_ips 2>/dev/null) || true; \
	if [ -z "$$IPS" ] || [ "$$IPS" = "[]" ]; then \
		echo "Error: No instance IPs found. Run 'make tf-apply' first."; exit 1; \
	fi; \
	echo "all:" > $(INVENTORY); \
	echo "  hosts:" >> $(INVENTORY); \
	INDEX=0; \
	for IP in $$(echo "$$IPS" | tr -d '[]"' | tr ',' ' '); do \
		echo "    cloud_1_instance_$$INDEX:" >> $(INVENTORY); \
		echo "      ansible_host: $$IP" >> $(INVENTORY); \
		INDEX=$$((INDEX + 1)); \
	done; \
	echo "" >> $(INVENTORY); \
	echo "  children:" >> $(INVENTORY); \
	echo "    prod:" >> $(INVENTORY); \
	echo "      hosts:" >> $(INVENTORY); \
	INDEX=0; \
	for IP in $$(echo "$$IPS" | tr -d '[]"' | tr ',' ' '); do \
		echo "        cloud_1_instance_$$INDEX:" >> $(INVENTORY); \
		INDEX=$$((INDEX + 1)); \
	done; \
	echo "" >> $(INVENTORY); \
	echo "  vars:" >> $(INVENTORY); \
	echo "    ansible_user: $(SSH_USER)" >> $(INVENTORY); \
	echo "    ansible_ssh_private_key_file: ./$(KEY_FILE)" >> $(INVENTORY); \
	echo "    ansible_python_interpreter: /usr/bin/python3" >> $(INVENTORY); \
	echo "Inventory generated with $$((INDEX)) host(s)."

# === Ansible === #
secrets-view:
	@ansible-vault view roles/cloud_1/vars/secrets.yml

secrets-edit:
	@ansible-vault edit roles/cloud_1/vars/secrets.yml

install: inventory
	@echo "Launching provisioning..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK)
	@echo ""
	@echo "Provisioning complete! Access your instances:"
	@INDEX=0; \
	for IP in $$(terraform -chdir=$(TF_DIR) output -json instance_ips 2>/dev/null | tr -d '[]"' | tr ',' ' '); do \
		echo "  Instance $$INDEX:"; \
		echo "    WordPress:  https://$$IP/"; \
		echo "    phpMyAdmin: https://$$IP/phpmyadmin/"; \
		INDEX=$$((INDEX + 1)); \
	done
	@echo "  SSH: make ssh N=<index>"

ssh:
	@IP=$$(terraform -chdir=$(TF_DIR) output -json instance_ips 2>/dev/null | tr -d '[]" ' | cut -d',' -f$$(($(N) + 1))); \
	if [ -z "$$IP" ]; then echo "Error: No instance at index $(N). Run 'make tf-apply' first."; exit 1; fi; \
	echo "Connecting to $(SSH_USER)@$$IP..."; \
	ssh -i $(KEY_FILE) $(SSH_USER)@$$IP

clean_known_hosts:
	@IPS=$$(terraform -chdir=$(TF_DIR) output -json instance_ips 2>/dev/null | tr -d '[]"' | tr ',' ' '); \
	if [ -z "$$IPS" ]; then echo "Error: No IPs found."; exit 1; fi; \
	for IP in $$IPS; do \
		echo "Removing $$IP from known_hosts..."; \
		ssh-keygen -R "$$IP"; \
	done

clean:
	@IPS=$$(terraform -chdir=$(TF_DIR) output -json instance_ips 2>/dev/null | tr -d '[]"' | tr ',' ' ') || true; \
	$(MAKE) tf-destroy; \
	for IP in $$IPS; do ssh-keygen -R "$$IP" 2>/dev/null; done
	rm -f $(KEY_FILE) $(KEY_FILE).pub $(INVENTORY)
