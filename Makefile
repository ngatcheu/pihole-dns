DIR             := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INVENTORY       := $(DIR)inventory.yml
PLAYBOOK_PIHOLE := $(DIR)playbook-pihole.yml
PLAYBOOK_NODES  := $(DIR)playbook-nodes.yml
ANSIBLE         := ansible-playbook

ifneq (,$(wildcard .env))
  include .env
  export
endif

.DEFAULT_GOAL := help

.PHONY: help install deploy deploy-pihole deploy-nodes dns ping check lint

help: ## Affiche l'aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

install: ## Installe les collections Ansible requises
	ansible-galaxy collection install -r $(DIR)collections/requirements.yml

deploy: install ## Installe Pi-hole ET configure les nœuds
	$(ANSIBLE) -i $(INVENTORY) $(PLAYBOOK_PIHOLE)
	$(ANSIBLE) -i $(INVENTORY) $(PLAYBOOK_NODES)

deploy-pihole: install ## Installe et configure Pi-hole uniquement
	$(ANSIBLE) -i $(INVENTORY) $(PLAYBOOK_PIHOLE)

deploy-nodes: install ## Configure le DNS sur les nœuds du cluster uniquement
	$(ANSIBLE) -i $(INVENTORY) $(PLAYBOOK_NODES)

dns: ## Met à jour uniquement les enregistrements DNS custom
	$(ANSIBLE) -i $(INVENTORY) $(PLAYBOOK_PIHOLE) --tags dns

ping: ## Vérifie la connectivité SSH vers tous les hôtes
	ansible -i $(INVENTORY) all -m ping

check: ## Dry-run sur tous les playbooks
	$(ANSIBLE) -i $(INVENTORY) $(PLAYBOOK_PIHOLE) --check --diff
	$(ANSIBLE) -i $(INVENTORY) $(PLAYBOOK_NODES) --check --diff

lint: ## Lint tous les playbooks avec ansible-lint
	ansible-lint $(PLAYBOOK_PIHOLE) $(PLAYBOOK_NODES)
