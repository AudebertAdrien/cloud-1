HOST_IP = 34.155.147.233

SSH_USER = cloud_1-user

INVENTORY = inventory
PLAYBOOK = provisioning.yml
KEY_FILE = cloud_1-key

.PHONY: all key install ssh clean_known_hosts help

key:
	@echo "Generating SSH key for user $(SSH_USER)..."
	ssh-keygen -t ed25519 -f $(KEY_FILE) -C "$(SSH_USER)" -N ""
	chmod 600 $(KEY_FILE)
	@echo "✅ Key generated!"
	@echo "👉 Copy the content of '$(KEY_FILE).pub' into the Google Cloud console (SSH Metadata)."

install:
	@echo "Launching provisioning on $(HOST_IP)..."
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --extra-vars "ansible_host=$(HOST_IP) ansible_user=$(SSH_USER)"

ssh:
	@echo "Connecting to $(SSH_USER)@$(HOST_IP)..."
	ssh -i $(KEY_FILE) $(SSH_USER)@$(HOST_IP)

clean_known_hosts:
	@echo "Removing $(HOST_IP) from known_hosts..."
	ssh-keygen -R $(HOST_IP)
