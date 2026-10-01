{
  den,
  inputs,
  ...
}: {
  den.hosts.aarch64-linux.moss = {
    instantiate = inputs.nixpkgs-moss.lib.nixosSystem;
  };

  den.aspects.moss = {
    includes = [den.aspects.home-assistant-service];

    nixos = {
      lib,
      pkgs,
      ...
    }: {
      imports = [inputs.nixos-hardware.nixosModules.raspberry-pi-5];

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-label/NIXOS_SD";
          fsType = "ext4";
        };
        "/boot/firmware" = {
          device = "/dev/disk/by-label/FIRMWARE";
          fsType = "vfat";
          options = ["nofail"];
        };
      };

      boot = {
        loader.grub.enable = false;
        loader.generic-extlinux-compatible.enable = true;
        zfs.forceImportRoot = false;
        initrd.systemd.tpm2.enable = false;
        supportedFilesystems.zfs = lib.mkForce false;
      };
      hardware.enableRedistributableFirmware = true;
      hardware.raspberry-pi.firmware = {
        enable = false;
        uboot.enable = true;
      };

      networking = {
        hostName = "moss";
        networkmanager.enable = true;
      };
      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";

      users.users.pablo = {
        isNormalUser = true;
        extraGroups = ["networkmanager" "wheel"];
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhIDSvStvZHDq665hZusi69KYs/SkO0yehByf0m3D/U pablo@lark-host-admin"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtRrsnLdZL1CpjtgSe4paqojnLwz+Vt1ih6r2mGZgT7 pablo@hazel-host-admin"
        ];
      };
      security.sudo.wheelNeedsPassword = false;
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = ["pablo"];
        };
      };

      environment.systemPackages = [pkgs.vim];
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["root" "pablo"];
      };
      system.stateVersion = "25.05";
    };
  };
}
