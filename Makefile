app-deploy: #Install site
	ansible-playbook ./ansible/playbook.yaml -i ./ansible/inventory.yml

infra-deploy:
	cd ./terraform && terraform apply

infra-check:
	cd ./terraform && terraform plan

terraform-init:
	cd ./terraform && terraform init

ansible-test:
	ansible -m ping all -i ./ansible/inventory.yml --vault-password-file ./ansible/vault-password-file

ansible-prepare: # install ansible roles and collection
	ansible-galaxy collection install -r requirements.yml
	ansible-galaxy role install -r requirements.yml

ansible-edit-secrets:
	ansible-vault edit ./ansible/group_vars/webservers/vault.yml

