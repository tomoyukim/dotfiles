SHELL := /bin/sh

USERNAME := tomoyukim
HOSTS := audrey silvie macbook

.DEFAULT_GOAL := help

.PHONY: help switch update-codex update-hermes $(HOSTS)

help:
	@printf '%s\n' \
		'Usage:' \
		'  make switch HOST=<host>  Switch to a host configuration' \
		'  make update-codex       Update the Codex package input' \
		'  make update-hermes      Update the Hermes package input' \
		'  make <host>              Switch to a specific host configuration' \
		'' \
		'Available hosts: $(HOSTS)'

switch:
	@test -n "$(HOST)" || { \
		echo 'Error: HOST is required (for example: make switch HOST=audrey)' >&2; \
		exit 1; \
	}
	home-manager switch --flake .#$(USERNAME)@$(HOST)

update-codex:
	nix flake update codex-nixpkgs

update-hermes:
	nix flake update hermes-agent

$(HOSTS):
	@$(MAKE) switch HOST=$@
