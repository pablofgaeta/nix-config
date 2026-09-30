{...}: {
  den.aspects.sketchybar.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.font-awesome];

    programs.sketchybar = {
      enable = true;
      config = {
        source = ./.;
        recursive = true;
      };
      extraPackages = [pkgs.aerospace];
      service.enable = true;
    };
  };
}
