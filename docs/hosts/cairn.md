# Cairn

Cairn is the headless NixOS server on the HP EliteDesk 800 G4 Mini. Its Disko configuration creates a GPT disk with a 1 GiB EFI System Partition and a LUKS-encrypted Btrfs filesystem containing `/` and `/nix`. It expects the Kioxia NVMe drive at `/dev/nvme0n1`.

## First installation

Boot a current NixOS minimal ISO in UEFI mode, connect it to the network, and clone this repository. Before partitioning the disk, verify its device path:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL
```

`hosts/_cairn/hardware-configuration.nix` defines Cairn's boot-module and CPU-microcode settings. `hosts/_cairn/disko.nix` defines its filesystem layout.

`disko` erases the configured disk. Run it only after confirming that `hosts/_cairn/disko.nix` names the Kioxia drive:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/ff8702b4de27f72b4c78573dfb89ec74e36abdf1#disko-install -- --write-efi-boot-entries --flake .#cairn --disk main /dev/nvme0n1
```

Set the `pablo` password before rebooting if console login is needed:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/ff8702b4de27f72b4c78573dfb89ec74e36abdf1 -- --mode mount --root-mountpoint /mnt --flake .#cairn
sudo nixos-enter --root /mnt -c 'passwd pablo'
```

After rebooting, update the installed system with:

```bash
NIX_HOST=cairn make nixos

# or remotely deploy (from another host)
make deploy-cairn
```
