{
  den,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.hazel = {};

  den.aspects.hazel = {
    includes = [
      den.aspects.bluetooth
      den.aspects.hyprland
      den.aspects.keyboard
      den.aspects.shell
      den.aspects.sunshine
    ];

    nixos = {
      lib,
      pkgs,
      ...
    }: {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.lanzaboote.nixosModules.lanzaboote
        (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
        ./_hazel/disko.nix
        ./_hazel/hardware-configuration.nix
      ];

      users.users.pablo = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "uinput"
          "wheel"
        ];
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhIDSvStvZHDq665hZusi69KYs/SkO0yehByf0m3D/U pablo@lark-host-admin"
        ];
      };

      boot = {
        binfmt.emulatedSystems = ["aarch64-linux"];
        initrd = {
          systemd.enable = true;
          luks.devices.cryptroot.crypttabExtraOpts = [
            "tpm2-device=auto"
          ];
        };

        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        loader = {
          systemd-boot.enable = lib.mkForce false;
          efi.canTouchEfiVariables = true;
        };
      };

      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "America/Los_Angeles";

      networking = {
        hostName = "hazel";
        networkmanager.enable = true;
      };

      nix = {
        package = pkgs.lix;
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      nixpkgs.config.allowUnfree = true;

      virtualisation.podman.enable = true;

      programs = {
        gamemode.enable = true;
        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc.lib
          ];
        };
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
      };

      environment.systemPackages = [
        pkgs.e2fsprogs
        pkgs.sbctl
      ];

      security.tpm2 = {
        enable = true;
        pkcs11.enable = true;
        tctiEnvironment.enable = true;
      };

      services = {
        displayManager.sddm = {
          enable = true;
          wayland.enable = false;
        };
        flatpak.enable = true;
        xserver.enable = true;
        lact.enable = true;
      };

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = ["pablo"];
        };
      };

      networking.firewall.allowedTCPPorts = [22];

      system.stateVersion = "26.05";
    };
  };
}
