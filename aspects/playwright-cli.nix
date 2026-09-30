{den, ...}: {
  den.aspects.playwright-cli = {
    includes = [den.aspects.skills];

    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.pablo.ai.playwrightCli;
    in {
      options.pablo.ai.playwrightCli = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install Playwright CLI and its shared agent skill.";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.buildNpmPackage {
            pname = "playwright-cli";
            version = "0.1.21";

            src = pkgs.fetchFromGitHub {
              owner = "microsoft";
              repo = "playwright-cli";
              rev = "74354ecc7a43da16d91a9bc54fa8db8283a3fcf5";
              hash = "sha256-ZHfQBZQejJKNYfhszd99i4GIzEpomBzX0/HkMK2T8DQ=";
            };

            npmDepsHash = "sha256-aTn5CFeAzoH4J+TYiM4HOULzWAeyU3xmD4wkQdsJrGY=";
            dontNpmBuild = true;
            env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
            nativeBuildInputs = [pkgs.makeWrapper];

            postInstall = lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              wrapProgram $out/bin/playwright-cli \
                --set-default PLAYWRIGHT_MCP_EXECUTABLE_PATH ${lib.getExe pkgs.chromium}
            '';

            meta = {
              description = "Playwright CLI for browser automation with agent skills";
              homepage = "https://github.com/microsoft/playwright-cli";
              license = lib.licenses.asl20;
              mainProgram = "playwright-cli";
              platforms = lib.platforms.unix;
            };
          };
          description = "Playwright CLI package with upstream skills in its source.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [cfg.package];
        pablo.ai.skills = {
          enable = lib.mkDefault true;
          sources.playwright-cli = "${cfg.package.src}/skills/playwright-cli";
        };
      };
    };
  };
}
