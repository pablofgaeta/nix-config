{inputs, ...}: {
  den.aspects.shell = {
    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: {
      # TODO: remove after migrating to bash-only
      _module.args.byta = inputs.byta;

      xdg.enable = true;
      xdg.binHome = "${config.home.homeDirectory}/.local/bin";

      home.sessionPath = [config.xdg.binHome];
      home.sessionVariables = {
        EDITOR = "nvim";
        LESSHISTFILE = "-";
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
        VISUAL = "nvim";
      };

      home.packages = with pkgs;
        [
          bat
          eza
          fd
          git-lfs
          jq
          noti
          ripgrep
          tree
          yq-go
          openssl_3
          gh
        ]
        # load bin programs
        ++ (map
          (name: pkgs.writeShellScriptBin name (builtins.readFile (./bin + "/${name}")))
          (builtins.attrNames (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ./bin))));
    };

    nixos = {pkgs, ...}: {
      programs = {
        bash.enable = true;
        fish.enable = true;
      };

      environment.shells = [
        pkgs.bashInteractive
        pkgs.fish
      ];
    };
  };
}
