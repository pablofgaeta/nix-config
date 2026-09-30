{inputs, ...}: {
  den.aspects.catppuccin.homeManager = {...}: {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha";
      accent = "mauve";

      # Neovim and Hyprland themes are managed outside of catppuccin/nix.
      hyprland.enable = false;
      nvim.enable = false;
      opencode.enable = false;
    };
  };
}
