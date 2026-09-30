{...}: {
  den.aspects.shell.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      cargo
      clippy
      eza
      rust-analyzer
      rustc
      rustfmt
    ];

    programs.bash = {
      enable = true;
      enableCompletion = true;
      package = pkgs.bashInteractive;
      historyControl = [
        "ignoreboth"
        "erasedups"
      ];
      historyFileSize = 100000;
      historyIgnore = [
        "clear"
        "exit"
        "history"
        "la"
        "ll"
        "ls"
      ];
      historySize = 50000;
      shellOptions = [
        "autocd"
        "checkwinsize"
        "cmdhist"
        "globstar"
        "histappend"
      ];
      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";
        cg = "cargo build";
        cr = "cargo run";
        ct = "cargo test";
        ff = "fastfetch";
        grep = "grep --color=auto";
        la = "eza -a --color=always --group-directories-first --icons=auto";
        ll = "eza -l --color=always --group-directories-first --icons=auto";
        ls = "eza -al --color=always --group-directories-first --icons=auto";
        lt = "eza -aT --color=always --group-directories-first --icons=auto";
        python = "python3";
        tarnow = "tar -acf";
        untar = "tar -zxvf";
        wget = "wget -c";
        docker = "podman";
        ghostscript = "/usr/bin/ghostscript";
      };
    };
  };
}
