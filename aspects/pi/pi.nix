{den, ...}: {
  den.aspects.pi = {
    includes = [
      den.aspects.agent-jj-checkpoint
      den.aspects.skills
      den.aspects.playwright-cli
    ];

    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.pablo.ai.pi;
      jsonFormat = pkgs.formats.json {};
      basePermissionConfig = builtins.fromJSON (builtins.readFile ./pi-permission-system.json);
      permissionConfig =
        basePermissionConfig
        // {
          permission =
            basePermissionConfig.permission
            // {
              skill = {"*" = "ask";} // lib.genAttrs (builtins.attrNames config.pablo.ai.skills.sources) (_: "allow");
            };
        };
    in {
      options.pablo.ai.pi = {
        context = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Optional AGENTS.md source for Pi.";
        };
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "git:github.com/ttttmr/pi-web-search@83ac115e87bce29cf4c93af329b94ce5c306eaa8"
            "npm:@gotgenes/pi-permission-system@31.1.2"
            "npm:pi-agent-browser-native@0.6.10"
            "npm:pi-btw@0.6.1"
            "git:github.com/pablofgaeta/pi-timer"
          ];
          description = "Pi extension package specs.";
        };
      };

      config = {
        pablo.ai.pi.context = ../shared/AGENTS.md;

        home.packages = [
          pkgs.pi-coding-agent
          pkgs.agent-browser
        ];

        home.file =
          {
            ".pi/agent/extensions/pi-permission-system/config.json".source = jsonFormat.generate "pi-permission-system.json" permissionConfig;
            ".pi/agent/extensions/remember-model.ts".source = ./pi-remember-model.ts;
            ".pi/agent/settings.json" = {
              source = jsonFormat.generate "pi-settings.json" {inherit (cfg) packages;};
              force = true;
            };
          }
          // lib.optionalAttrs (cfg.context != null) {
            ".pi/agent/AGENTS.md".source = cfg.context;
          };

        pablo.ai.agentJjCheckpoint.pi.enable = lib.mkDefault true;
      };
    };
  };
}
