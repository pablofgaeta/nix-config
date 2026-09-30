{...}: {
  den.aspects.development.homeManager = {
    config,
    lib,
    pkgs,
    ...
  } @ args: let
    goPath = "${config.home.homeDirectory}/go";
    # NixOS hosts with virtualisation.podman provide podman and its policy.json.
    hostHasPodman = args.osConfig.virtualisation.podman.enable or false;
  in {
    programs.go = {
      enable = true;
      env.GOPATH = goPath;
    };

    home.sessionVariables.GOPATH = goPath;
    home.sessionPath = ["${goPath}/bin"];

    home.packages = with pkgs;
      [
        gitleaks
        redis
        rumdl
      ]
      ++ lib.optional (!hostHasPodman) podman;
  };
}
