{...}: {
  den.aspects.ghostty.homeManager = {pkgs, ...}: {
    fonts.fontconfig.enable = true;
    home.packages = [pkgs.nerd-fonts.jetbrains-mono];

    programs.ghostty = {
      package =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.ghostty-bin
        else pkgs.ghostty;
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      installVimSyntax = true;
      settings = {
        font-family = "JetBrains Mono";
        window-padding-y = 1;
        window-padding-balance = false;
        command = "${pkgs.bashInteractive}/bin/bash --login";
        macos-auto-secure-input = true;
        macos-option-as-alt = true;
        background-opacity = 0.8;
        background-blur = true;
        clipboard-read = "allow";
        clipboard-write = "allow";
        copy-on-select = "clipboard";
        keybind = [
          "super+,=text:ghostty +edit-config"
          "super+shift+r=reset"
        ];
        shell-integration-features = "ssh-env,ssh-terminfo";
      };
    };
  };
}
