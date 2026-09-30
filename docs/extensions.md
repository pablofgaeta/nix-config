# Extending the Flake

`lib.mkConfiguration` evaluates this flake's Den modules with additional modules. A consumer flake can add targets without copying this configuration:

```nix
outputs = inputs:
  inputs.public.lib.mkConfiguration {
    extraSpecialArgs.consumerInputs = inputs;
    modules = [
      ({den, consumerInputs, ...}: {
        den.homes.x86_64-linux."user@consumer-host" = {
          aspect = den.aspects.consumer-home;
          userName = "user";
          pkgs = consumerInputs.nixpkgs.legacyPackages.x86_64-linux;
        };
        den.aspects.consumer-home.homeManager = {
          home.username = "user";
          home.homeDirectory = "/home/user";
        };
      })
    ];
  };
```

The extension must follow this flake's `nixpkgs` input and keep consumer modules in the consumer flake. `extraSpecialArgs` cannot replace the public flake's `inputs`; use a separate name such as `consumerInputs`.
