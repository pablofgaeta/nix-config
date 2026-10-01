NIX_HOST ?= lark
NIX_USER ?= pablogaeta
MOSS_SSH ?= pablo@moss
CAIRN_SSH ?= pablo@cairn

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
	@if [ "$(NIX_HOST)" = moss ]; then echo "Use make deploy-moss from Hazel" >&2; exit 1; fi
	sudo nixos-rebuild switch --flake path:.#$(NIX_HOST)

.PHONY: deploy-moss
deploy-moss:
	nix run path:.#nixos-rebuild -- switch --flake path:.#moss --target-host "$(MOSS_SSH)" --elevate=sudo

.PHONY: deploy-cairn
deploy-cairn:
	nix run path:.#nixos-rebuild -- switch --flake path:.#cairn --target-host "$(CAIRN_SSH)" --build-host "$(CAIRN_SSH)" --elevate=sudo --ask-elevate-password

# Lint
.PHONY: lint
lint:
	nix run path:.#formatter
