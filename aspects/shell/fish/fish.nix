{...}: {
  den.aspects.shell.homeManager = {
    byta,
    pkgs,
    ...
  }: {
    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "plugin-git";
          src = pkgs.fishPlugins.plugin-git.src;
        }
        {
          name = "nvm";
          src = pkgs.fishPlugins.nvm.src;
        }
        {
          name = "colored_man_pages";
          src = pkgs.fishPlugins.colored-man-pages.src;
        }
        {
          # GCP profile context switching. https://github.com/pablofgaeta/byta.fish
          # Pinned via the `byta` flake input; update with `nix flake update byta`.
          name = "byta";
          src = byta;
        }
        {
          name = "fishtape";
          src = pkgs.fishPlugins.fishtape.src;
        }
      ];
    };

    xdg.configFile = {
      "fish/completions" = {
        source = ./completions;
        recursive = true;
      };
      "fish/conf.d" = {
        source = ./conf.d;
        recursive = true;
      };
      "fish/functions" = {
        source = ./functions;
        recursive = true;
      };
    };
  };
}
