app-deploy: #Install site
	ansible-playbook ./ansible/playbook.yml -i ./ansible/inventory.yml --vault-password-file ./vault.password

app-deploy-test:
	ansible -m ping all -i ./ansible/inventory.yml --vault-password-file ./vault.password

app-deploy-prepare: # install ansible roles and collection
	ansible-galaxy collection install -r requirements.yml
	ansible-galaxy role install -r requirements.yml

app-edit-secrets:
	ansible-vault edit ./ansible/group_vars/webservers/vault.yml	

infra-deploy:
	cd ./terraform && terraform apply -auto-approve

infra-destroy:
	cd ./terraform && terraform destroy -auto-approve

infra-check:
	cd ./terraform && terraform plan

infra-prepare:
	bash ./scripts/decrypt-data.sh ./secrets/encrypted/ ./vault.password
	cp ./secrets/encrypted/yc.secrets.auto.tfvars ./terraform/prepare-backend/yc.secrets.auto.tfvars

infra-init:
	cd ./terraform && terraform init -backend-config="./state.config"

infra-init-backend:
	cd ./terraform/prepare-backend && terraform init -auto-approve

infra-create-backend:
	cd ./terraform/prepare-backend && terraform apply -auto-approve

infra-secret-encrypt:
	bash ./scripts/encrypt-data.sh ./secrets/decrypted/ ./secrets/encrypted/ ./vault.password
	