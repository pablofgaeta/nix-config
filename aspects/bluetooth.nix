{...}: {
  den.aspects.bluetooth = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.blueman];
      systemd.user.services.blueman-applet = {
        Unit = {
          Description = "Blueman applet";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.blueman}/bin/blueman-applet";
          Restart = "on-failure";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };

    nixos = {pkgs, ...}: {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;
      environment.systemPackages = [pkgs.bluez];
    };
  };
}
