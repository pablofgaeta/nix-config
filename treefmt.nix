{
  lib,
  pkgs,
  ...
}: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    fish_indent.enable = true;

    prettier = {
      enable = true;
      includes = [
        "*.css"
        "*.html"
        "*.js"
        "*.json"
        "*.md"
        "*.yaml"
        "*.yml"
      ];
    };

    ruff-format = {
      enable = true;
      includes = [
        "*.ipynb"
        "*.py"
      ];
    };

    stylua.enable = true;
  };

  settings.formatter.tombi = {
    command = lib.getExe pkgs.tombi;
    options = [
      "format"
      "--offline"
    ];
    includes = ["*.toml"];
  };
}
