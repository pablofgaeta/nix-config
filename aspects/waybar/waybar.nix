{...}: {
  den.aspects.waybar.homeManager = {
    pkgs,
    lib,
    ...
  }: let
    # Waybar's own `include` mechanism is replaced by merging every module
    # file into a single bar definition. Reading the JSON (instead of
    # re-typing it) keeps the Nerd Font glyphs byte-for-byte exact.
    readModule = f: builtins.fromJSON (builtins.readFile f);

    baseConfig = builtins.removeAttrs (readModule ./config.jsonc) ["include"];

    moduleFiles = [
      ./modules/groups.jsonc
      ./modules/distro.jsonc
      ./modules/storage.jsonc
      ./modules/system.jsonc
      ./modules/power-profiles-daemon.jsonc
      ./modules/workspace.jsonc
      ./modules/idle-ihibitor.jsonc
      ./modules/audio.jsonc
      ./modules/connections.jsonc
      ./modules/battery.jsonc
      ./modules/clock.jsonc
      ./modules/tray-notif.jsonc
    ];

    modules = builtins.foldl' (acc: f: acc // readModule f) {} moduleFiles;
  in {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings.mainBar = baseConfig // modules;
    };

    # Catppuccin (autoEnable) injects its `@define-color` palette into
    # `programs.waybar.style` via mkBefore. mkAfter guarantees our rules land
    # after those definitions so the `@mauve`/`@surface0`/... references resolve.
    programs.waybar.style = lib.mkAfter ''
      * {
        margin: 0;
        padding: 0;
        min-height: 0px;
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
      }

      window#waybar {
        background: transparent;
      }

      /* ===== state colors ===== */
      #custom-tray-arrow.inhibited-none,
      #custom-tray-arrow.dnd-none,
      #battery.charging,
      #power-profiles-daemon.power-saver {
        color: @green;
      }

      #idle_inhibitor.activated,
      #cpu.warning,
      #disk.warning,
      #memory.warning,
      #battery.warning:not(.charging),
      #custom-tray-arrow.notification,
      #custom-tray-arrow.dnd-notification,
      #custom-tray-arrow.inhibited-notification {
        color: @yellow;
      }

      #network.disabled,
      #cpu.critical,
      #disk.critical,
      #memory.critical,
      #temperature.critical,
      #battery.critical:not(.charging),
      #power-profiles-daemon.performance,
      #custom-tray-arrow.dnd-inhibited-none,
      #custom-tray-arrow.dnd-inhibited-notification {
        color: @red;
      }

      /* ===== workspaces ===== */
      #workspaces {
        margin: 4px 5px;
        padding: 6px 6px;
        background-color: @surface0;
        border-radius: 20px;
      }

      #workspaces button {
        min-width: 32px;
        padding: 0 4px;
        margin: 0 2px;
        background: transparent;
        border-radius: 16px;
        color: @lavender;
        transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
      }

      #workspaces button.active {
        padding: 0 12px;
        margin: 0 2px;
        background-color: @mauve;
        color: @base;
      }

      #workspaces button.special:not(.active) {
        color: @lavender;
      }

      #workspaces button:hover {
        background-color: @surface1;
        color: @mauve;
      }

      #workspaces button.active:hover {
        background-color: @mauve;
        color: @base;
      }

      #workspaces button.empty {
        color: @overlay0;
      }

      #workspaces button.urgent {
        color: @red;
      }

      #workspaces button label:first-child {
        margin-right: 8px;
      }

      #workspaces button label:last-child {
        margin-left: 2px;
      }

      /* ===== module-independent widgets ===== */
      #distro-group {
        margin: 4px 5px;
        background-color: @surface0;
        border-radius: 20px;
        color: @mauve;
      }

      #custom-distro {
        color: @mauve;
        padding: 6px 15px 6px 10px;
      }

      #custom-terminal {
        color: @green;
        padding: 0px 10px;
      }

      #custom-code {
        color: @blue;
        padding: 0px 10px;
      }

      #custom-office {
        color: @peach;
        padding: 0px 10px;
      }

      #custom-obsidian {
        color: @mauve;
        padding: 0px 10px;
      }

      #custom-files {
        color: @yellow;
        padding: 0px 10px 0px 8px;
      }

      #custom-spotify {
        color: @green;
        padding: 0px 10px;
      }

      #custom-browser {
        color: @peach;
        padding: 0px 15px 0px 10px;
      }

      #power-profiles-daemon,
      #idle_inhibitor {
        margin: 4px 5px;
        padding: 6px 15px 6px 10px;
        background-color: @surface0;
        border-radius: 20px;
        color: @subtext1;
      }

      /* ===== module capsules ===== */
      #audio,
      #connections,
      #system,
      #storage {
        margin: 4px 5px;
        padding: 6px 6px;
        background-color: @surface0;
        border-radius: 20px;
        color: @subtext1;
      }

      #disk,
      #memory,
      #cpu,
      #temperature,
      #bluetooth {
        margin-right: 2px;
        padding: 0 8px;
      }

      #network {
        padding: 0px 10px 0px 4px;
      }

      #pulseaudio {
        margin-right: 12px;
        margin-left: 8px;
      }

      /* ===== tray ===== */
      #tray-group {
        margin: 4px 5px;
        background-color: @surface0;
        border-radius: 20px;
      }

      #custom-tray-arrow {
        padding: 6px 14px 6px 10px;
        color: @mauve;
      }

      #tray {
        padding: 6px 10px;
      }

      #tray > .passive,
      #tray > .active,
      #tray > .needs-attention {
        -gtk-icon-effect: none;
      }

      /* ===== battery & clock ===== */
      #battery {
        margin: 4px 5px;
        padding: 6px 16px;
        background-color: @surface0;
        border-radius: 20px;
        color: @subtext1;
      }

      #clock {
        margin: 4px 5px;
        padding: 6px 10px 6px 16px;
        background-color: @surface0;
        border-radius: 20px;
        color: @subtext1;
      }

      /* ===== volume slider ===== */
      #pulseaudio-slider {
        margin: 4px 5px;
        padding: 0 2px;
        background-color: transparent;
        border-radius: 20px;
      }

      #pulseaudio-slider trough {
        min-height: 10px;
        min-width: 80px;
        border-radius: 10px;
        background-color: @surface2;
      }

      #pulseaudio-slider highlight {
        min-height: 10px;
        border-radius: 10px;
        background-color: @subtext1;
      }

      #pulseaudio-slider slider {
        min-height: 12px;
        min-width: 12px;
        margin: -2px 0;
        border-radius: 100%;
        background-color: @mauve;
      }
    '';

    home.packages = with pkgs; [
      waybar
      pavucontrol
      blueman
    ];
  };
}
