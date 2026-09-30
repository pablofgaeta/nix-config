{
  description = "Pablo's cross-platform machine configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    den.url = "github:denful/den";

    import-tree.url = "github:denful/import-tree";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pgvim = {
      url = "github:pablofgaeta/pgvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zjai = {
      url = "github:pablofgaeta/zjai";
      inputs.crane.follows = "lanzaboote/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    byta = {
      url = "github:pablofgaeta/byta.fish";
      flake = false;
    };

    zjump = {
      url = "github:pablofgaeta/zjump";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin theming for nix darwin/home manager modules
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    mkConfiguration = {
      modules ? [],
      extraSpecialArgs ? {},
    }:
      (inputs.nixpkgs.lib.evalModules {
        modules =
          [
            inputs.den.flakeModule
            ./outputs.nix
            (inputs.import-tree ./aspects)
            (inputs.import-tree ./hosts)
            (inputs.import-tree ./homes)
            {
              den.default.homeManager = {
                home.stateVersion = "26.05";
                manual.manpages.enable = false;
                manual.html.enable = false;
                xdg.userDirs.enable = true;
              };
            }
          ]
          ++ modules;
        specialArgs = extraSpecialArgs // {inherit inputs;};
      }).config.flake;
  in
    mkConfiguration {
      modules = [
        {
          flake.lib.mkConfiguration = mkConfiguration;
        }
      ];
    };
}
