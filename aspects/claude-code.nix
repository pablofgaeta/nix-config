# Claude Code (Anthropic's official CLI) config.
{den, ...}: {
  den.aspects.claude-code = {
    includes = [
      den.aspects.agent-jj-checkpoint
      den.aspects.mcp
      den.aspects.skills
    ];

    homeManager = {
      config,
      lib,
      ...
    }: let
      cfg = config.pablo.ai.claudeCode;
      zjaiHooks = {
        UserPromptSubmit = [
          {
            hooks = [
              {
                type = "command";
                command = "$HOME/.local/libexec/zjai-notify claude working";
              }
            ];
          }
        ];
        PostToolUse = [
          {
            hooks = [
              {
                type = "command";
                command = "$HOME/.local/libexec/zjai-notify claude working";
              }
            ];
          }
        ];
        PostToolUseFailure = [
          {
            hooks = [
              {
                type = "command";
                command = "$HOME/.local/libexec/zjai-notify claude error";
              }
            ];
          }
        ];
        Notification = [
          {
            matcher = "permission_prompt";
            hooks = [
              {
                type = "command";
                command = "$HOME/.local/libexec/zjai-notify claude blocked";
              }
            ];
          }
        ];
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "$HOME/.local/libexec/zjai-notify claude done";
              }
            ];
          }
        ];
        SessionEnd = [
          {
            hooks = [
              {
                type = "command";
                command = "$HOME/.local/libexec/zjai-notify claude idle";
              }
            ];
          }
        ];
      };
    in {
      options.pablo.ai.claudeCode = {
        context = lib.mkOption {
          type = lib.types.lines;
          default = "";
        };
        zjaiNotifications = lib.mkEnableOption "zjai Claude Code status notifications";
      };

      config = {
        programs.claude-code = {
          enable = true;
          enableMcpIntegration = true;
          context = cfg.context;

          settings = {
            includeCoAuthoredBy = false;
            hooks = lib.mkIf cfg.zjaiNotifications zjaiHooks;

            permissions = {
              allow = ["Bash"];
              ask = [
                "Bash(curl:*)"
                "Bash(gh api:*)"
                "Bash(gh gist create:*)"
                "Bash(gh issue close:*)"
                "Bash(gh issue comment:*)"
                "Bash(gh issue create:*)"
                "Bash(gh issue edit:*)"
                "Bash(gh pr close:*)"
                "Bash(gh pr comment:*)"
                "Bash(gh pr create:*)"
                "Bash(gh pr edit:*)"
                "Bash(gh pr review:*)"
                "Bash(gh release:*)"
                "Bash(gh secret set:*)"
                "Bash(gh workflow run:*)"
                "Bash(git commit:*)"
                "Bash(git push:*)"
                "Bash(jj git push:*)"
              ];
              deny = [
                "Bash(gh pr merge:*)"
                "Bash(gh repo delete:*)"
              ];
            };
          };
        };

        pablo.ai.agentJjCheckpoint.claudeCode.enable = lib.mkDefault true;

        pablo.ai.claudeCode = {
          context = builtins.readFile ./shared/AGENTS.md;
          zjaiNotifications = true;
        };
      };
    };
  };
}
