{
  den,
  inputs,
  ...
}: {
  den.hosts.x86_64-linux.cairn = {};

  den.aspects.cairn = {
    includes = [den.aspects.shell];

    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        inputs.disko.nixosModules.disko
        inputs.lanzaboote.nixosModules.lanzaboote
        (inputs.nixpkgs + "/nixos/modules/installer/scan/not-detected.nix")
        ./_cairn/disko.nix
        ./_cairn/hardware-configuration.nix
      ];

      boot = {
        initrd = {
          systemd.enable = true;
          luks.devices.cryptroot.crypttabExtraOpts = ["tpm2-device=auto"];
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

      users.users.pablo = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhIDSvStvZHDq665hZusi69KYs/SkO0yehByf0m3D/U pablo@lark-host-admin"
        ];
      };

      i18n.defaultLocale = "en_US.UTF-8";
      time.timeZone = "America/Los_Angeles";

      networking = {
        hostName = "cairn";
        useDHCP = lib.mkDefault true;
        firewall = {
          enable = true;
          allowedTCPPorts = [22];
        };
      };

      nix = {
        package = pkgs.lix;
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      programs.fish.enable = true;

      environment.systemPackages = with pkgs; [
        git
        gnumake
        sbctl
      ];

      security.tpm2 = {
        enable = true;
        pkcs11.enable = true;
        tctiEnvironment.enable = true;
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

      zramSwap.enable = true;

      system.stateVersion = "26.05";
    };
  };
}
