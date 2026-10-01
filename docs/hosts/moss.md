# Moss

Raspberry Pi 5 running Home Assistant on NixOS (`aarch64-linux`). The flake target and network hostname are `moss`.

## Configuration

- `hosts/moss.nix`: Den host, Pi hardware, storage, and administrative access.
- `aspects/home-assistant.nix`: Home Assistant, integrations, HomeKit firewall rules, and discovery.

Moss uses the separate `nixpkgs-moss` input, pinned to the standalone repository's original revision. The original nixos-hardware revision, SD-card labels, boot configuration, and `system.stateVersion` are preserved. Matching build inputs allow reuse of the original kernel if it is available locally or from a binary cache; Hazel does not automatically fetch existing builds from the Pi. The existing python-kasa override is retained; validate TP-Link devices before removing it.

Home Assistant permits writable configuration. Back up `/var/lib/hass` separately, including UI-managed configuration and the database. Git is not a backup of the running instance.

## Deploy from Hazel

Before the first deployment:

1. `hosts/moss.nix` authorizes Lark's and Hazel's admin public keys. Keep private keys outside this repository. If Hazel's key is not yet installed on the running Pi, install its public half using existing access before deploying.
2. Apply Hazel's Home Manager configuration: `NIX_HOST=hazel NIX_USER=pablo make home`. Its SSH settings select `~/.ssh/hazel-host-admin` for `moss`. Confirm key-based access and noninteractive sudo: `ssh -o ControlPath=none -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no moss 'sudo -n true'`.
3. Apply Hazel's system configuration if ARM emulation is not already enabled: `NIX_HOST=hazel make nixos`. The host declares `boot.binfmt.emulatedSystems = ["aarch64-linux"]` for local ARM builds through QEMU.

UniFi reserves `192.168.1.64` for Moss and provides the local DNS record `moss.localdomain`. Clients use the gateway's DNS and the DHCP search domain `localdomain` to resolve the short name `moss`. SSH uses that short name without a DNS override. Home Assistant is available at `http://moss:8123`.

Keep an existing Pi SSH session open during deployment. From Hazel:

```sh
make deploy-moss
```

This builds on Hazel and activates on Moss using remote sudo. It does not switch Hazel's system configuration. Override the destination with `MOSS_SSH=pablo@<pi-ip>` if needed.

Password login is disabled; the administrator retains passwordless sudo and trusted Nix access. The Pi does not need GitHub credentials for deployment. No SOPS secrets or private keys were imported. Removing provisioning does not revoke the old key at GitHub; audit the existing Pi key and revoke it separately if unused.

## Updates

Update Moss independently with `nix flake update nixpkgs-moss nixos-hardware`. A blanket `nix flake update` updates these inputs too. Updates may require rebuilding the kernel. Review the lockfile diff and build without activation before deploying:

```sh
nix build path:.#nixosConfigurations.moss.config.system.build.toplevel --no-link
```
