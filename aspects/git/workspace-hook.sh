# Run pre-commit or lefthook inside any jj workspace (default, nested, or outside)
# with GIT_DIR and GIT_WORK_TREE configured so hooks target the workspace rather
# than the main repo root or failing on missing git metadata.
set -euo pipefail

mode=${1:?usage: workspace-hook <pre-commit|lefthook|auto> [args...]}
shift

ws_root="$(env -u GIT_DIR -u GIT_WORK_TREE jj workspace root 2>/dev/null || pwd)"
cd "$ws_root"

default_root="$(env -u GIT_DIR -u GIT_WORK_TREE jj --no-pager workspace list -T 'if(name == "default", root ++ "\n")' 2>/dev/null | head -n1)"
git_dir=""
if [[ -n $default_root && -d $default_root/.git ]]; then
    git_dir="$default_root/.git"
elif [[ -d .git ]]; then
    git_dir="$ws_root/.git"
fi

apply_git_env() {
    if [[ -n $git_dir ]]; then
        export GIT_DIR="$git_dir"
        export GIT_WORK_TREE="$ws_root"
    fi
}

if [[ $mode == "auto" ]]; then
    if [[ -f .pre-commit-config.yaml ]]; then
        mode="pre-commit"
    else
        for candidate in lefthook.yml lefthook.yaml .lefthook.yml .lefthook.yaml lefthook.toml lefthook.json; do
            if [[ -f $candidate ]]; then
                mode="lefthook"
                break
            fi
        done
    fi
fi

collect_files() {
    files=()
    local raw
    raw=$(env -u GIT_DIR -u GIT_WORK_TREE jj --no-pager diff -r "${JJ_REVSET:-trunk()..@}" --name-only 2>/dev/null || env -u GIT_DIR -u GIT_WORK_TREE jj --no-pager diff -r @ --name-only 2>/dev/null || true)
    [[ -z $raw ]] && return 0
    while IFS= read -r f; do
        if [[ -f $f ]]; then
            files+=("$f")
        fi
    done <<<"$raw"
}

case $mode in
pre-commit)
    pre_commit=(pre-commit)
    if ! command -v pre-commit >/dev/null 2>&1; then
        pre_commit=(uvx pre-commit)
    fi
    if (($# > 0)); then
        apply_git_env
        exec "${pre_commit[@]}" "$@"
    fi
    collect_files
    if ((${#files[@]} == 0)); then
        echo "jj pre-commit: no changed files to check"
        exit 0
    fi
    apply_git_env
    exec "${pre_commit[@]}" run --files "${files[@]}"
    ;;
lefthook)
    if (($# > 0)); then
        apply_git_env
        exec lefthook "$@"
    fi
    collect_files
    if ((${#files[@]} == 0)); then
        echo "jj lefthook: no changed files to check"
        exit 0
    fi
    file_args=()
    for f in "${files[@]}"; do
        file_args+=(--file "$f")
    done
    apply_git_env
    exec lefthook run pre-commit --no-auto-install "${file_args[@]}"
    ;;
*)
    echo "workspace-hook: no supported hook config (.pre-commit-config.yaml or lefthook.yml) found in $ws_root" >&2
    exit 1
    ;;
esac
