{
  den,
  inputs,
  ...
}: let
  pkgsFor = import ./_lib/pkgs-for.nix {inherit inputs;};
in {
  den.homes.aarch64-darwin."pablogaeta@lark" = {
    aspect = den.aspects.lark-home;
    userName = "pablogaeta";
    pkgs = pkgsFor "aarch64-darwin";
  };

  den.aspects.lark-home = {
    includes = [
      # ai
      den.aspects.claude-code
      den.aspects.pi
      den.aspects.llama
      # development
      den.aspects.git
      den.aspects.pgvim
      # desktop
      den.aspects.aerospace
      den.aspects.browser
      den.aspects.catppuccin
      den.aspects.development
      den.aspects.ghostty
      den.aspects.javascript
      den.aspects.playwright-cli
      den.aspects.python
      den.aspects.shell
      den.aspects.sketchybar
      den.aspects.ssh
      den.aspects.zellij
      # misc
    ];

    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        inputs.zjai.homeManagerModules.default
      ];

      home.username = "pablogaeta";
      home.homeDirectory = "/Users/pablogaeta";
      home.packages = with pkgs; [
        coreutils
        automake
        csvkit
        csvq
        graphviz
        hadolint
        terraform
        tflint
        jmeter
        osv-scanner
        poppler
        postgresql
        qrencode
        tesseract
        moonlight-qt
        google-cloud-sdk
        google-chrome
        ffmpeg
        probe-rs-tools
        kompose
        kubectl
        arp-scan
        gdb
        libtool
        nmap
        libpkgconf
        qemu
        vscode
        spotify
        utm
        nodejs
        sqlitebrowser
      ];

      programs.man.generateCaches = false;
      pablo.zellij = {
        zjumpPackage = inputs.zjump.packages.${pkgs.stdenv.hostPlatform.system}.default;
        sessionizer.rootDirs = [
          "${config.home.homeDirectory}/workspace/gh/pablofgaeta"
          "${config.home.homeDirectory}/workspace/local"
          "${config.home.homeDirectory}/workspace/tmp"
        ];
      };
      home.sessionPath = [
        "/usr/lib/adcs/symlinks"
        "/Applications/SuperCollider.app/Contents/MacOS"
        "/Applications/CMake.app/Contents/bin"
        "/Applications/Racket/bin"
        "/opt/homebrew/opt/libtool/libexec/gnubin"
      ];

      programs.ssh.settings.moss = {
        HostName = "home-assistant";
        User = "pablo";

        # Home Assistant
        "LocalForward 8123" = "localhost:8123";
      };

      programs.ssh.settings.hazel = {
        HostName = "hazel";
        User = "pablo";
        ForwardAgent = "yes";
        ControlPersist = "yes";

        # Port forwarding

        # Web
        "LocalForward 8080" = "localhost:8080";
        "LocalForward 8000" = "localhost:8000";

        # Hub dev server (5174 locally)
        "LocalForward 5174" = "localhost:5173";

        # Backend
        "LocalForward 3000" = "localhost:3000";

        # Marimo
        "LocalForward 2718" = "localhost:2718";

        # pi
        "LocalForward 8787" = "localhost:8787";

        # llama.cpp
        "LocalForward 8012" = "localhost:8012";

        # mdts (markdown tree viewer)
        "LocalForward 8521" = "localhost:8521";
      };

      programs.git.settings = {
        user.signingkey = "~/.ssh/personal.pub";
        core.sshCommand = "ssh -i ~/.ssh/personal";
      };

      programs.jujutsu.settings = {
        user = {
          name = "Pablo Gaeta";
          email = "37568237+pablofgaeta@users.noreply.github.com";
        };

        # jj signs independently of git; give it the same key git uses here.
        signing.key = "~/.ssh/personal.pub";
      };
    };
  };
}
