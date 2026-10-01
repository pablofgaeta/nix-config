{
  inputs,
  lib,
  ...
}: let
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];

  homeManagerApp = system: {
    type = "app";
    program = lib.getExe inputs.home-manager.packages.${system}.home-manager;
  };

  treefmtEval =
    lib.genAttrs systems (system:
      inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} ./treefmt.nix);
in {
  flake = {
    apps = {
      aarch64-darwin = {
        home-manager = homeManagerApp "aarch64-darwin";
        formatter = {
          type = "app";
          program = lib.getExe treefmtEval.aarch64-darwin.config.build.wrapper;
        };
        darwin-rebuild = {
          type = "app";
          program = lib.getExe inputs.darwin.packages.aarch64-darwin.darwin-rebuild;
        };
      };
      x86_64-linux = {
        nixos-rebuild = {
          type = "app";
          program = lib.getExe inputs.nixpkgs.legacyPackages.x86_64-linux.nixos-rebuild;
        };
        home-manager = homeManagerApp "x86_64-linux";
        formatter = {
          type = "app";
          program = lib.getExe treefmtEval.x86_64-linux.config.build.wrapper;
        };
      };
    };

    checks = {
      aarch64-linux.moss-system = inputs.self.nixosConfigurations.moss.config.system.build.toplevel;
      aarch64-darwin = {
        lark-system = inputs.self.darwinConfigurations.lark.system;
        pablogaeta-at-lark-home = inputs.self.homeConfigurations."pablogaeta@lark".activationPackage;
      };
      x86_64-linux = {
        formatting = treefmtEval.x86_64-linux.config.build.check inputs.self;
        hazel-system = inputs.self.nixosConfigurations.hazel.config.system.build.toplevel;
        pablo-at-hazel-home = inputs.self.homeConfigurations."pablo@hazel".activationPackage;
      };
    };

    devShells =
      lib.mapAttrs (system: treefmt: let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            treefmt.config.build.wrapper
            alejandra
            fish
            gitleaks
            lefthook
            prettier
            ruff
            stylua
            tombi
          ];
        };
      })
      treefmtEval;

    formatter = lib.mapAttrs (_: treefmt: treefmt.config.build.wrapper) treefmtEval;
  };
}
