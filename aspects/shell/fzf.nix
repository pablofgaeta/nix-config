{...}: {
  den.aspects.shell.homeManager = {lib, ...}: {
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    programs.bash = {
      # Zoxide runs at 2000, this init must run afterwards.
      initExtra = lib.mkOrder 2001 ''
        _fzf_setup_completion dir cd
      '';
    };
  };
}
