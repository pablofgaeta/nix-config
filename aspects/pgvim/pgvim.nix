{inputs, ...}: {
  den.aspects.pgvim.homeManager = {pkgs, ...}: {
    imports = [inputs.pgvim.homeManagerModules.default];

    home.packages = [pkgs.svelte-language-server];

    programs.pgvim = {
      extraRuntimePaths = [./.];
      extraLuaConfig = builtins.readFile ./init.lua;
    };
  };
}
