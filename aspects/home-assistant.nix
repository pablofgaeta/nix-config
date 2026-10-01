{...}: {
  den.aspects.home-assistant-service.nixos = {pkgs, ...}: {
    services.home-assistant = {
      enable = true;
      configWritable = true;
      package = pkgs.home-assistant.override {
        packageOverrides = _self: super: {
          python-kasa = super.python-kasa.overridePythonAttrs (_oldAttrs: {
            version = "0.10.2";
            src = pkgs.fetchFromGitHub {
              owner = "python-kasa";
              repo = "python-kasa";
              rev = "ff11447b9575b1352a6064cb47492e30432117a7";
              hash = "sha256-XxyaqlmnlJc8Y17fkAZBLuQnCBZVcl6E5kv+2KEeKZo=";
            };
          });
        };
      };
      extraComponents = [
        "cync"
        "default_config"
        "esphome"
        "homekit"
        "met"
        "radio_browser"
        "tplink"
        "zeroconf"
      ];
      config = {
        default_config = {};
        http.server_host = ["0.0.0.0" "::"];
      };
    };

    # HomeKit Bridge requires inbound connections and mDNS discovery.
    networking.firewall.allowedTCPPorts = [8123 21064];
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
