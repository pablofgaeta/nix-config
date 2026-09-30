{...}: {
  den.aspects.keyboard = {
    homeManager = {...}: {
      # Manually install when contents change:
      # $ sudo install -m 0644 ~/rd75/99-rd75-via.rules /etc/udev/rules.d/
      # $ sudo udevadm control --reload-rules
      home.file."rd75/99-rd75-via.rules".text = ''
        # Allow WebHID/VIA to configure this specific Womier RD75 model.
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="36b0", ATTRS{idProduct}=="3003", MODE:="0666"
      '';
    };

    nixos = {...}: {
      console.useXkbConfig = true;

      services = {
        udev.extraRules = ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="36b0", ATTRS{idProduct}=="3003", MODE:="0666"
        '';
        xserver.xkb.options = "ctrl:nocaps";
      };
    };

    darwin = {...}: {
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };
  };
}
