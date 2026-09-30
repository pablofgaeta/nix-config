NIX_HOST ?= lark
NIX_USER ?= pablogaeta

# Build Home Manager

.PHONY: home
home:
	nix run path:.#home-manager -- switch -b backup --flake path:.#$(NIX_USER)@$(NIX_HOST)

# Build Nix Darwin

.PHONY: darwin
darwin:
	sudo nix run path:.#darwin-rebuild -- switch --flake path:.#$(NIX_HOST)

# Build NixOS

.PHONY: nixos
nixos:
	sudo nixos-rebuild switch --flake path:.#$(NIX_HOST)

# Lint
.PHONY: lint
lint:
	nix run path:.#formatter
