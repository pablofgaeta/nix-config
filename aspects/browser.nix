{...}: {
  den.aspects.browser.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.brave];
  };
}
