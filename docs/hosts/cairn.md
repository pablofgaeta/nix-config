# Cairn

Cairn is the headless NixOS server on the HP EliteDesk 800 G4 Mini. Its Disko configuration creates a GPT disk with a 1 GiB EFI System Partition and a LUKS-encrypted Btrfs filesystem containing `/` and `/nix`. It expects the Kioxia NVMe drive at `/dev/nvme0n1`.

## First installation

Boot a current NixOS minimal ISO in UEFI mode and connect Ethernet. Clone the Cairn configuration:

```bash
git clone --branch cairn https://github.com/pablofgaeta/nix-config.git
cd nix-config
```

Verify the target before partitioning:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL
```

`disko` erases the configured disk. Run it only after confirming that `hosts/_cairn/disko.nix` names the Kioxia drive:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/ff8702b4de27f72b4c78573dfb89ec74e36abdf1#disko-install -- --write-efi-boot-entries --flake .#cairn --disk main /dev/nvme0n1
```

Set the console password before rebooting:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/ff8702b4de27f72b4c78573dfb89ec74e36abdf1 -- --mode mount --root-mountpoint /mnt --flake .#cairn
sudo nixos-enter --root /mnt -c 'passwd pablo'
```

Reboot, remove the USB drive, and enter the LUKS passphrase.

## Deploying updates

On Cairn, with a local clone:

```bash
NIX_HOST=cairn make nixos
```

From Lark, deploy remotely:

```bash
make deploy-cairn
```

`deploy-cairn` builds on Cairn and prompts for the `pablo` sudo password.

## Secure Boot

Cairn uses Lanzaboote and stores its `sbctl` keys in `/var/lib/sbctl`.

1. Create keys before applying the Secure Boot configuration:

   ```bash
   sudo nix run nixpkgs#sbctl -- create-keys
   ```

2. Deploy the Cairn configuration with `make deploy-cairn`.

3. Verify the active UKIs and key state:

   ```bash
   sudo sbctl status
   sudo bootctl list
   ```

   Lanzaboote thin UKIs require payloads under `/boot/EFI/nixos/`. Do not delete files from that directory.

4. On the HP EliteDesk firmware:

   - Set a BIOS administrator password.
   - Under **Security → BIOS Sure Start**, disable **Sure Start Secure Boot Keys Protection**. Save, reboot, and enter firmware again.
   - Under **Security → Secure Boot Configuration**, disable Legacy Support, clear Secure Boot keys, and leave **Enable MS UEFI CA Key** disabled.
   - Do not restore factory Secure Boot keys or use HP Device Guard's configure/clear-on-next-boot actions.

5. Boot NixOS in Setup Mode and enroll the keys:

   ```bash
   sudo sbctl enroll-keys
   ```

6. Return to firmware, enable Secure Boot, and reboot.

Verify the completed setup:

```bash
sudo sbctl status
sudo sbctl verify
```

`sbctl status` must report Setup Mode disabled and Secure Boot enabled. Keep the LUKS passphrase as recovery access.

## TPM2 LUKS unlock

Verify TPM2:

```bash
systemd-analyze has-tpm2
```

After Secure Boot is enabled, enroll TPM2 against PCR 7:

```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-main-luks
```

Reboot to verify automatic unlock. A firmware reset, Secure Boot key change, or PCR 7 change can require the retained LUKS passphrase.
