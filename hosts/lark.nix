{
  den,
  inputs,
  ...
}: {
  den.hosts.aarch64-darwin.lark = {};

  den.aspects.lark = {
    includes = [den.aspects.keyboard];

    darwin = {pkgs, ...}: {
      nix = {
        enable = true;
        package = pkgs.lix;
        channel.enable = false;
        settings = {
          accept-flake-config = true;
          experimental-features = ["nix-command" "flakes"];
        };
      };

      nixpkgs.hostPlatform = "aarch64-darwin";
      system.primaryUser = "pablogaeta";
      system.stateVersion = 7;

      # Uncomment to match linux/windows ordering.
      # system.keyboard.swapLeftCommandAndLeftAlt = true;
      # system.keyboard.swapLeftCtrlAndFn = true;

      users.users.pablogaeta = {
        home = "/Users/pablogaeta";
        shell = pkgs.bashInteractive;
      };

      programs.bash.enable = true;
      programs.fish.enable = true;
      environment.shells = [
        pkgs.bashInteractive
        pkgs.fish
      ];
      environment.variables = {
        LESSHISTFILE = "-";
      };

      homebrew = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        onActivation = {
          autoUpdate = false;
          cleanup = "zap";
          upgrade = true;
        };
        taps = [];
        casks = [
          "bitwarden"
          "raycast"
          "steam"
        ];
        brews = ["mole"];
      };

      system.defaults.NSGlobalDomain._HIHideMenuBar = true;

      security.pam.services.sudo_local.touchIdAuth = true;
      nixpkgs.config.allowUnfree = true;
    };
  };
}
