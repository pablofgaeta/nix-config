{...}: {
  den.aspects.shell.homeManager = {lib, ...}: {
    # Requires a Nerd Font; see den/aspects/desktop/ghostty.nix.
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        # Language version lookups (java especially) do not fit in 200ms.
        command_timeout = 500;

        format = lib.concatStrings [
          # left: stable context, reads as a sentence
          "\${env_var.SHPOOL_SESSION_NAME}"
          "$os"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$hg_branch"
          "$hg_state"
          "$direnv"
          "$docker_context"
          # right: variable-length detail, pinned to the terminal edge
          "$fill"
          "$c"
          "$cpp"
          "$rust"
          "$golang"
          "$nodejs"
          "$java"
          "$python"
          "$time"
          "$line_break"
          "$character"
        ];

        fill.symbol = " ";

        env_var.SHPOOL_SESSION_NAME = {
          format = "[ $env_value ](subtext0)";
        };

        os = {
          disabled = true;
          format = "[$symbol ]($style)";
          style = "peach";
          symbols = {
            Alpine = "";
            Amazon = "";
            Android = "";
            AOSC = "";
            Arch = "󰣇";
            Artix = "󰣇";
            CentOS = "";
            Debian = "󰣚";
            EndeavourOS = "";
            Fedora = "󰣛";
            Gentoo = "󰣨";
            Linux = "󰌽";
            Macos = "󰀵";
            Manjaro = "";
            Mint = "󰣭";
            NixOS = "";
            Pop = "";
            Raspbian = "󰐿";
            Redhat = "󱄛";
            RedHatEnterprise = "󱄛";
            SUSE = "";
            Ubuntu = "󰕈";
            Windows = "󰍲";
          };
        };

        hostname = {
          style = "bold peach";
        };

        directory = {
          format = "[$path]($style) ";
          style = "bold blue";
          fish_style_pwd_dir_length = 1;
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = "󰝚 ";
            "Pictures" = " ";
            "Developer" = "󰲋 ";
          };
        };

        git_branch = {
          symbol = "";
          format = "on [$symbol $branch]($style) ";
          style = "bold mauve";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "peach";
        };

        hg_branch = {
          disabled = false;
          symbol = "";
          format = "on [$symbol $branch]($style) ";
          style = "bold mauve";
        };

        hg_state = {
          disabled = false;
          format = "([$state( $progress_current/$progress_total)]($style) )";
          style = "peach";
        };

        direnv = {
          disabled = false;
          symbol = "";
          format = "with [$symbol $loaded]($style)[$allowed](red) ";
          style = "overlay2";
          loaded_msg = "";
          unloaded_msg = "";
          allowed_msg = "";
          not_allowed_msg = "!";
          denied_msg = "x";
        };

        docker_context = {
          symbol = "";
          format = "via [$symbol $context]($style) ";
          style = "bold sapphire";
        };

        # Right-hand modules drop the "via" prose: it reads as a sentence flowing
        # left, but as repetition once right-aligned.
        c = {
          symbol = "";
          format = "[$symbol $version]($style) ";
          style = "bold blue";
        };

        cpp = {
          symbol = "";
          format = "[$symbol $version]($style) ";
          style = "bold blue";
        };

        rust = {
          symbol = "";
          format = "[$symbol $version]($style) ";
          style = "bold peach";
        };

        golang = {
          symbol = "";
          format = "[$symbol $version]($style) ";
          style = "bold sky";
        };

        nodejs = {
          disabled = true;
          symbol = "";
          format = "[$symbol $version]($style) ";
          style = "bold green";
        };

        java = {
          symbol = "";
          format = "[$symbol $version]($style) ";
          style = "bold red";
        };

        python = {
          symbol = "";
          format = "[$symbol $version]($style) ";
          style = "bold yellow";
        };

        time = {
          disabled = false;
          time_format = "%R";
          format = "[ $time]($style)";
          style = "overlay2";
        };

        line_break.disabled = false;

        character = {
          disabled = false;
          success_symbol = "[λ](bold green)";
          error_symbol = "[λ](bold red)";
          vimcmd_symbol = "[λ](bold green)";
          vimcmd_replace_one_symbol = "[v](bold mauve)";
          vimcmd_replace_symbol = "[v](bold mauve)";
          vimcmd_visual_symbol = "[v](bold yellow)";
        };
      };
    };
  };
}
