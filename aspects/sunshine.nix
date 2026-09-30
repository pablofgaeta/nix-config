{...}: {
  den.aspects.sunshine.nixos.services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
  };
}
