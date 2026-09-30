{den, ...}: {
  den.aspects.agent-jj-checkpoint.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.pablo.ai.agentJjCheckpoint;
    checkpointHooks = {
      UserPromptSubmit = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.nix-profile/bin/agent-jj-checkpoint before-agent-turn";
            }
          ];
        }
      ];
      Stop = [
        {
          hooks = [
            {
              type = "command";
              command = "$HOME/.nix-profile/bin/agent-jj-checkpoint after-agent-turn";
            }
          ];
        }
      ];
    };
  in {
    options.pablo.ai.agentJjCheckpoint = {
      pi.enable = lib.mkEnableOption "Jujutsu checkpoints around Pi agent turns";
      claudeCode.enable = lib.mkEnableOption "Jujutsu checkpoints around Claude agent turns";
    };

    config = {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "agent-jj-checkpoint";
          runtimeInputs = [
            pkgs.jq
            pkgs.jujutsu
          ];
          text = builtins.readFile ./agent-jj-checkpoint.sh;
        })
      ];

      home.file = lib.optionalAttrs cfg.pi.enable {
        ".pi/agent/extensions/jj-checkpoint.ts".source = ./pi-jj-checkpoint.ts;
      };

      programs.claude-code.settings.hooks = lib.mkIf cfg.claudeCode.enable checkpointHooks;
    };
  };
}
