deploy: #Install site
	ansible-playbook ./playbook.yaml -i ./inventory.yml

prepare: # install ansible roles and collection
	ansible-galaxy collection install -r requirements.yml
	ansible-galaxy role install -r requirements.yml

edit-secrets:
	ansible-vault edit group_vars/webservers/vault.yml
