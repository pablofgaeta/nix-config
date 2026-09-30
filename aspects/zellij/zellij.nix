{...}: {
  den.aspects.zellij.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.pablo.zellij;
    pluginDir = "${config.home.homeDirectory}/.config/zellij/plugins";
    sessionizerRootDirs = lib.concatStringsSep ";" cfg.sessionizer.rootDirs;
    sessionizerIndividualDirs = lib.concatStringsSep ";" cfg.sessionizer.individualDirs;
    zellij-sessionizer = pkgs.fetchurl {
      url = "https://github.com/laperlej/zellij-sessionizer/releases/download/v0.5.0/zellij-sessionizer.wasm";
      hash = "sha256-xBhBwCPnToH5mg/Y2V4FBO0gLfLNuSYE31HJ5OoLoFs=";
    };
    zjumpConfig = lib.optionalString (cfg.zjumpPackage != null) ''
      shared_among "normal" "locked" {
          bind "Alt w" {
              LaunchOrFocusPlugin "file:${pluginDir}/zjump.wasm" {
                  floating true
                  move_to_focused_tab true
              };
          }
          bind "Alt m" {
              LaunchOrFocusPlugin "file:${pluginDir}/zjump.wasm" {
                  floating true
                  move_to_focused_tab true
                  mode "marks"
              };
          }
      }
    '';
    sessionizerConfig = ''
      session {
          bind "g" {
              LaunchOrFocusPlugin "file:${pluginDir}/zellij-sessionizer.wasm" {
                  floating true
                  move_to_focused_tab true
                  cwd "/"
                  root_dirs "${sessionizerRootDirs}"
                  individual_dirs "${sessionizerIndividualDirs}"
              };
              SwitchToMode "Locked"
          }
      }
      shared_among "normal" "locked" {
          bind "Alt s" {
              LaunchOrFocusPlugin "file:${pluginDir}/zellij-sessionizer.wasm" {
                  floating true
                  move_to_focused_tab true
                  cwd "/"
                  root_dirs "${sessionizerRootDirs}"
                  individual_dirs "${sessionizerIndividualDirs}"
              };
          }
      }
    '';
  in {
    options.pablo.zellij = {
      zjumpPackage = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
        description = "Package containing bin/zjump.wasm. Set to null to disable zjump keybinds.";
      };

      sessionizer.rootDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Directories whose immediate children are selectable zellij-sessionizer projects.";
      };

      sessionizer.individualDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Directories added directly as selectable zellij-sessionizer projects.";
      };
    };

    config = {
      programs.zellij = {
        enable = true;

        settings = {
          show_startup_tips = false;
          pane_frames = true;
          pane_frame_style = "full";
          stacked_pane_list = false;
          theme = lib.mkForce "catppuccin-mocha-surface";
        };

        themes."catppuccin-mocha-surface" = ./themes/catppuccin-mocha-surface.kdl;

        extraConfig =
          lib.removeSuffix "}" (lib.trim (builtins.readFile ./unlock-first.kdl))
          + "\n"
          + zjumpConfig
          + sessionizerConfig
          + "}\n";
      };

      home.file.".config/zellij/plugins/zellij-sessionizer.wasm".source = zellij-sessionizer;
      home.file.".config/zellij/plugins/zjump.wasm" = lib.mkIf (cfg.zjumpPackage != null) {
        source = "${cfg.zjumpPackage}/bin/zjump.wasm";
      };
    };
  };
}
