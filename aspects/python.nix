{...}: {
  den.aspects.python.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      pyrefly
      python314
    ];

    programs.uv = {
      enable = true;
      settings.pip.index-url = "https://pypi.org/simple";
    };

    xdg.configFile."pip/pip.conf".text = ''
      [global]
      index-url = https://pypi.org/simple/
    '';
  };
}
