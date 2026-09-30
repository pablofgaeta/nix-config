{den, ...}: {
  den.aspects.mcp = {
    includes = [den.aspects.playwright-cli];

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        bun
        uv
      ];

      programs.mcp = {
        enable = true;
        servers = {
          nix = {
            enabled = false;
            command = "uvx";
            args = ["mcp-nixos"];
          };

          git = {
            enabled = false;
            url = "https://gitmcp.io/docs";
          };

          playwright = {
            enabled = false;
            command = "bunx";
            args = ["@playwright/mcp@latest"];
          };

          filesystem = {
            enabled = false;
            command = "bunx";
            args = [
              "-y"
              "@modelcontextprotocol/server-filesystem"
              "~/workspace"
            ];
          };
        };
      };
    };
  };
}
