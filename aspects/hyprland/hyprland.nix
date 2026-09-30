{...}: {
  den.aspects.hyprland = {
    homeManager = {
      config,
      pkgs,
      ...
    }: let
      wallpaper = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.gnomeFilePath;
    in {
      services.mako = {
        enable = true;
        settings.default-timeout = 5000;
      };
      services.hyprpolkitagent.enable = true;
      services.hypridle.enable = true;

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        systemd.enable = false;

        extraConfig = ''
          package.path = "${config.xdg.configHome}/hypr/?.lua;${config.xdg.configHome}/hypr/?/init.lua;" .. package.path

          terminal = "ghostty"
          fileManager = "dolphin"
          menu = "rofi -show drun -show-icons"
          browser = "google-chrome-stable"

          require("monitors")
          require("autostart")
          require("input")
          require("binds")
          require("style")
          require("rules")
        '';

        extraLuaFiles = {
          monitors = {
            content = ./lua/monitors.lua;
            autoLoad = false;
          };
          autostart = {
            content = ./lua/autostart.lua;
            autoLoad = false;
          };
          input = {
            content = ./lua/input.lua;
            autoLoad = false;
          };
          binds = {
            content = ./lua/binds.lua;
            autoLoad = false;
          };
          style = {
            content = ./lua/style.lua;
            autoLoad = false;
          };
          rules = {
            content = ./lua/rules.lua;
            autoLoad = false;
          };
        };
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          wallpaper = {
            monitor = "";
            path = "${wallpaper}";
            fit_mode = "cover";
          };
        };
      };

      programs.hyprlock = {
        enable = true;
        package = null;
      };

      xdg.configFile."background".source = wallpaper;

      home.packages = with pkgs; [
        hyprpaper
        hyprcursor
        hyprpicker
        hyprsunset
        rofi
        cliphist
        wl-clipboard
        kdePackages.dolphin
        (writeShellScriptBin "fix_lockscreen" ''
          hyprctl --instance 0 eval 'hl.config({misc={allow_session_lock_restore = 1}}); hl.exec_cmd("hyprlock")'
        '')
      ];
    };

    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.hyprlock];

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
    };
  };
}
