{...}: {
  den.aspects.wlogout.homeManager = {
    lib,
    pkgs,
    ...
  }: let
    icon = name:
      pkgs.runCommand "wlogout-${name}.png" {} ''
        ${pkgs.librsvg}/bin/rsvg-convert \
          --width 128 \
          --height 128 \
          ${./icons}/${name}.svg > $out
      '';
  in {
    home.packages = [pkgs.nunito];

    programs.wlogout = {
      enable = true;
      layout = [
        {
          action = "hyprlock";
          keybind = "l";
          label = "lock";
          text = "Lock";
        }
        {
          action = "systemctl hibernate";
          keybind = "h";
          label = "hibernate";
          text = "Hibernate";
        }
        {
          action = "uwsm stop";
          keybind = "e";
          label = "logout";
          text = "Logout";
        }
        {
          action = "systemctl poweroff";
          keybind = "s";
          label = "shutdown";
          text = "Shutdown";
        }
        {
          action = "systemctl suspend";
          keybind = "u";
          label = "suspend";
          text = "Suspend";
        }
        {
          action = "systemctl reboot";
          keybind = "r";
          label = "reboot";
          text = "Reboot";
        }
      ];

      style = lib.mkAfter ''
        window {
          background-color: rgba(17, 17, 27, 0.78);
        }

        button {
          margin: 0;
          padding: 100px 16px 18px;
          border: none;
          border-radius: 20px;
          background-position: center;
          background-repeat: no-repeat;
          background-size: 62px;
          box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
          color: #1e1e2e;
          font-family: "Nunito";
          font-size: 16px;
          font-weight: 800;
          transition: background-size 140ms ease-out, box-shadow 140ms ease-out;
        }

        button:hover,
        button:active {
          background-size: 70px;
          outline: none;
          box-shadow: 0 12px 28px rgba(0, 0, 0, 0.45);
        }

        button:focus {
          outline: none;
          box-shadow: 0 0 0 5px rgba(255, 255, 255, 0.9), 0 8px 20px rgba(0, 0, 0, 0.3);
        }

        button:focus:hover {
          background-size: 70px;
          box-shadow: 0 0 0 5px #ffffff, 0 12px 28px rgba(0, 0, 0, 0.45);
        }

        #lock,
        #lock:hover,
        #lock:focus,
        #lock:active {
          background-color: #b4befe;
          background-image: url("${icon "lock"}");
        }

        #hibernate,
        #hibernate:hover,
        #hibernate:focus,
        #hibernate:active {
          background-color: #cba6f7;
          background-image: url("${icon "hibernate"}");
        }

        #logout,
        #logout:hover,
        #logout:focus,
        #logout:active {
          background-color: #89b4fa;
          background-image: url("${icon "logout"}");
        }

        #shutdown,
        #shutdown:hover,
        #shutdown:focus,
        #shutdown:active {
          background-color: #f38ba8;
          background-image: url("${icon "shutdown"}");
        }

        #suspend,
        #suspend:hover,
        #suspend:focus,
        #suspend:active {
          background-color: #f9e2af;
          background-image: url("${icon "suspend"}");
        }

        #reboot,
        #reboot:hover,
        #reboot:focus,
        #reboot:active {
          background-color: #fab387;
          background-image: url("${icon "reboot"}");
        }
      '';
    };
  };
}
