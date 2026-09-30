{...}: {
  den.aspects.shell.homeManager.programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    silent = true;
    nix-direnv.enable = true;
  };
}
