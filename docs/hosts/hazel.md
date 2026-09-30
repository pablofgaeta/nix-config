# Hazel

Hazel is a NixOS system with its user environment managed by Home Manager.

After the first system rebuild, set the user password from the root account:

```bash
passwd pablo
```

## Secure Boot and TPM2 Unlock

Hazel uses Lanzaboote for Secure Boot signing and systemd TPM2 unlock for the LUKS root device. Nix declares boot signing and TPM support, but enrollment is a one-time machine operation that writes UEFI NVRAM and the LUKS header.

### Install Lanzaboote

Create signing keys before the first Lanzaboote rebuild. Lanzaboote requires `/var/lib/sbctl/keys/db/db.pem` when it installs the bootloader. A failed install can advance the NixOS system profile while leaving the EFI System Partition incomplete.

```bash
cd ~/nix-config
sudo nix run nixpkgs#sbctl -- create-keys
NIX_HOST=hazel make nixos
```

Do not continue if the rebuild reports `Failed to install bootloader`. Confirm every active boot artifact is signed and the current entry is a Lanzaboote UKI under `/EFI/Linux/`:

```bash
sudo sbctl verify
sudo bootctl list
```

An unsigned file under `/boot/EFI/nixos/` may be a legacy systemd-boot artifact. Before moving it, confirm that `bootctl list` and the loader configuration do not reference it:

```bash
sudo rg -n 'EFI/nixos' /boot/loader
```

### Enroll Secure Boot Keys

On the MSI firmware, select Custom Mode, disable factory-key provisioning, and delete all Secure Boot variables. Do not restore or enroll factory-default keys. After booting NixOS, confirm that Setup Mode is enabled and Secure Boot is disabled:

```bash
sudo sbctl status
```

If enrollment reports immutable efivarfs files, clear the immutable bit only on the paths named by the error. This configuration installs `chattr` through `e2fsprogs`.

```bash
sudo chattr -i /sys/firmware/efi/efivars/KEK-* /sys/firmware/efi/efivars/db-*
sudo sbctl enroll-keys --microsoft
sudo sbctl verify
```

Microsoft certificates are required for the Option ROM in Hazel's boot chain. Do not use `--yes-this-might-brick-my-machine` to work around an EFI-variable permission error; it does not bypass firmware write protection.

Reboot into UEFI, enable Secure Boot without restoring factory keys, then boot NixOS and verify:

```bash
sudo sbctl status
sudo sbctl verify
sudo bootctl status
```

`sbctl status` must report Setup Mode disabled and Secure Boot enabled before TPM2 enrollment.

### Enroll TPM2 Unlock

Verify the LUKS partition with `lsblk -f`. `hosts/_hazel/disko.nix` expects the root LUKS partition at `/dev/nvme0n1p2`.

```bash
lsblk -f
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
sudo reboot
```

Keep the passphrase enrolled as recovery. Re-enroll TPM2 after Secure Boot key changes, a firmware reset, or another change that affects PCR 7.

### Recover an Incomplete Bootloader Install

First disable Secure Boot in UEFI. From a NixOS live USB, unlock and mount the installed root at `/mnt` and its EFI System Partition at `/mnt/boot`. Then force the current system profile to reinstall the bootloader:

```bash
sudo nixos-enter --root /mnt -c \
  'NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot'
```

Before enabling Secure Boot again, boot NixOS normally and repeat the `sbctl verify` and `bootctl list` checks.
