{...}: {
  den.aspects.git.homeManager = {pkgs, ...}: let
    workspace-hook = pkgs.writeShellApplication {
      name = "workspace-hook";
      runtimeInputs = [
        pkgs.git
        pkgs.jujutsu
        pkgs.lefthook
        pkgs.uv
      ];
      text = builtins.readFile ./workspace-hook.sh;
    };

    jj-pull = pkgs.writeShellApplication {
      name = "jj-pull";
      runtimeInputs = [pkgs.jujutsu];
      text = ''
        jj git fetch "$@"
        jj rebase --destination 'trunk()'
      '';
    };
  in {
    home.packages = [
      workspace-hook
      pkgs.ruff
    ];

    programs.jujutsu = {
      enable = true;
      settings = {
        # Auto-track and thus auto-create local new bookmarks from origin only.
        # Other remotes still require explicit `jj bookmark track`.
        remotes.origin.auto-track-bookmarks = "*";

        # Autosign commits we author.
        signing.backend = "ssh";
        signing.behavior = "own";
        signing.backends.ssh.program = "${pkgs.openssh}/bin/ssh-keygen";

        # `jj fix` rewrites a whole stack and works in secondary workspaces,
        # where git-based hook runners resolve the wrong root. Tools run in
        # lexicographic name order, each fed the previous one's output.
        fix.tools = {
          "01-ruff-check" = {
            command = [
              "ruff"
              "check"
              "--fix"
              "--exit-zero"
              "--stdin-filename"
              "$path"
              "-"
            ];
            patterns = [
              "glob:'**/*.py'"
              "glob:'**/*.pyi'"
            ];
          };
          "02-ruff-format" = {
            command = [
              "ruff"
              "format"
              "--stdin-filename"
              "$path"
              "-"
            ];
            patterns = [
              "glob:'**/*.py'"
              "glob:'**/*.pyi'"
            ];
          };
          # Sorts last, so its failure in non-treefmt repos is only stderr noise:
          # a failing tool leaves the prior tool's output intact.
          treefmt = {
            command = [
              "treefmt"
              "--stdin"
              "$path"
            ];
            patterns = ["all()"];
          };
        };

        aliases = {
          pre-commit = [
            "util"
            "exec"
            "--"
            "${workspace-hook}/bin/workspace-hook"
            "pre-commit"
          ];
          lefthook = [
            "util"
            "exec"
            "--"
            "${workspace-hook}/bin/workspace-hook"
            "lefthook"
          ];
          hook = [
            "util"
            "exec"
            "--"
            "${workspace-hook}/bin/workspace-hook"
            "auto"
          ];
          pull = [
            "util"
            "exec"
            "--"
            "${jj-pull}/bin/jj-pull"
          ];
        };
      };
    };

    programs.git = {
      enable = true;

      settings = {
        core = {
          excludesfile = "~/.gitignore";
          ignorecase = false;
        };

        init.defaultBranch = "main";
        # Tools like lazy.nvim that expect .git refs as plain files need this format.
        init.defaultRefFormat = "files";
        pull.rebase = true;
        push.autoSetupRemote = true;
        push.default = "current";

        diff.algorithm = "histogram";
        pager.branch = false;

        alias = {
          count-lines = ''! git log --author="$1" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' #'';
          contributions = ''! git log --numstat --no-merges --pretty=format:"AUTH:%aN" -- "''${1:-.}" | awk '/^AUTH:/ { auth = substr($0, 6); if (auth != "") { author_commits[auth]++; total_commits++ }; next } /^[0-9\-]/ { added = ($1 == "-" ? 0 : $1); author_lines[auth] += added; total_lines += added } END { for (auth in author_commits) { c_pct = (total_commits > 0) ? (author_commits[auth] / total_commits * 100) : 0; l_pct = (total_lines > 0) ? (author_lines[auth] / total_lines * 100) : 0; printf "%s\t%d\t%.2f%%\t%d\t%.2f%%\n", auth, author_commits[auth], c_pct, author_lines[auth], l_pct } }' | sort -rn -t$'\t' -k3 | awk -F'\t' 'BEGIN { print "| Username | Commits | % Commits | Lines Written | % Lines |"; print "|---|---|---|---|---|" } { print "| " $1 " | " $2 " | " $3 " | " $4 " | " $5 " |" }' #'';
        };

        filter.lfs = {
          required = true;
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
        };

        gpg.format = "ssh";
        commit.gpgsign = true;
        "gpg \"ssh\"".program = "${pkgs.openssh}/bin/ssh-keygen";
        # "gpg \"ssh\"".allowedSignersFile = "~/.ssh/allowed_signers";

        # Google Cloud Source Repositories credential helper + cookiefile.
        credential."https://source.developers.google.com".helper = "gcloud.sh";
        http.cookiefile = "~/.gitcookies";
      };
    };
  };
}
