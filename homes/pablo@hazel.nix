{
  den,
  inputs,
  ...
}: let
  pkgsFor = import ./_lib/pkgs-for.nix {inherit inputs;};
in {
  den.homes.x86_64-linux."pablo@hazel" = {
    aspect = den.aspects.hazel-home;
    userName = "pablo";
    pkgs = pkgsFor "x86_64-linux";
  };

  den.aspects.hazel-home = {
    includes = [
      # agents
      den.aspects.llama
      den.aspects.pi
      den.aspects.claude-code
      # development
      den.aspects.git
      den.aspects.pgvim
      # desktop
      den.aspects.bluetooth
      den.aspects.browser
      den.aspects.catppuccin
      den.aspects.development
      den.aspects.ghostty
      den.aspects.hyprland
      den.aspects.javascript
      den.aspects.playwright-cli
      den.aspects.python
      den.aspects.shell
      den.aspects.ssh
      den.aspects.waybar
      den.aspects.wlogout
      den.aspects.zellij
      # misc
    ];

    homeManager = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        inputs.zjai.homeManagerModules.default
      ];

      home.username = "pablo";
      home.homeDirectory = "/home/pablo";
      pablo.zellij = {
        zjumpPackage = inputs.zjump.packages.${pkgs.stdenv.hostPlatform.system}.default;
        sessionizer.rootDirs = [
          "${config.home.homeDirectory}/workspace/gh/pablofgaeta"
          "${config.home.homeDirectory}/workspace/local"
        ];
      };

      home.packages = with pkgs; [
        coreutils
        discord
        google-chrome
        spotify
        vscode
        terraform
        osv-scanner
        bibata-cursors
        grimblast
        # build-tools
        gcc
        gnumake
        pkg-config
        autoconf
        automake
        libtool
      ];

      programs.ssh.settings.moss = {
        HostName = "moss";
        User = "pablo";
        IdentityFile = "~/.ssh/hazel-host-admin";
        IdentitiesOnly = "yes";
      };

      programs.git.settings = {
        user.signingkey = "~/.ssh/gh.pub";
        core.sshCommand = "ssh -i ~/.ssh/gh";
      };

      programs.jujutsu.settings = {
        user = {
          name = "Pablo Gaeta";
          email = "37568237+pablofgaeta@users.noreply.github.com";
        };

        # jj signs independently of git; give it the same key git uses here.
        signing.key = "~/.ssh/gh.pub";
      };
    };
  };
}
