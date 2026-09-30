{...}: {
  den.aspects.javascript.homeManager = {...}: {
    programs.bun.enable = true;
    programs.npm = {
      enable = true;
      settings.registry = "https://registry.npmjs.org/";
    };
  };
}
