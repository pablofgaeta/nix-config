phase=${1:-checkpoint}
print=${AGENT_JJ_CHECKPOINT_PRINT:-}
if [ "${2:-}" = --print ]; then
  print=1
fi

stdin_json=
if [ ! -t 0 ]; then
  stdin_json=$(cat || true)
fi

tool=${2:-}
if [ "$tool" = --print ]; then
  tool=${3:-}
fi
if [ -z "$tool" ] && [ -n "$stdin_json" ]; then
  tool=$(printf '%s' "$stdin_json" | jq -r '.tool_name // .tool // empty' 2>/dev/null || true)
fi
tool=${tool:-unknown}

case "$tool" in
  find|grep|ls|read) exit 0 ;;
esac

cwd=${AGENT_JJ_CWD:-}
if [ -z "$cwd" ] && [ -n "$stdin_json" ]; then
  cwd=$(printf '%s' "$stdin_json" | jq -r '.cwd // .workspace.current_dir // empty' 2>/dev/null || true)
fi
cwd=${cwd:-$PWD}

if ! cd "$cwd" || ! jj --no-pager workspace root >/dev/null 2>&1; then
  exit 0
fi

op_template='id.short() ++ " " ++ description ++ "\n"'
operation_before=$(jj --no-pager --ignore-working-copy op log -n 1 --no-graph -T "$op_template" 2>/dev/null || true)
status=$(jj --no-pager status --color=never 2>/dev/null || true)
operation_after=$(jj --no-pager --ignore-working-copy op log -n 1 --no-graph -T "$op_template" 2>/dev/null || true)

if [ -z "$status" ]; then
  exit 0
fi

verb=checked
if [ -n "$operation_before" ] && [ -n "$operation_after" ] && [ "$operation_before" != "$operation_after" ]; then
  verb=created
fi

if [ "$print" = 1 ]; then
  printf 'jj checkpoint %s %s' "$verb" "$phase"
  if [ -n "$tool" ] && [ "$tool" != unknown ]; then
    printf ' %s' "$tool"
  fi
  if [ -n "$operation_after" ]; then
    printf ': %s\n' "$operation_after"
    operation_id=${operation_after%% *}
  else
    printf ': unknown operation\n'
    operation_id=unknown
  fi

  if [ "${AGENT_JJ_CHECKPOINT_VERBOSE:-}" = 1 ]; then
    printf '%s\n' "$status"
    printf '%s\n' "Revert via \`jj op log\` if needed."
  else
    changed_count=$(printf '%s\n' "$status" | awk '/^[[:space:]]*[A-Z?] / { count++ } END { print count + 0 }')
    if [ "$changed_count" = 0 ]; then
      printf '%s\n' "No working-copy changes. Revert via \`jj op log\`."
    else
      printf "%s\n" "Changed files: $changed_count. Inspect via \`jj op diff --operation $operation_id --patch\`; revert via \`jj op log\`."
    fi
  fi
fi
