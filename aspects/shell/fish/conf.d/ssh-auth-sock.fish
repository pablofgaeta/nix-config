# Keep SSH agent forwarding alive across reconnects.
#
# sshd mints a fresh forwarded-agent socket per connection (~/.ssh/agent/s.*)
# and unlinks it on disconnect. Processes that outlive the connection (zellij
# panes, agent sessions) keep the old path and lose the agent. Since consumers
# resolve SSH_AUTH_SOCK at connect() time, pointing them at a stable symlink
# that each new login re-points lets them recover without a restart.

# TODO: make shell-agnostic?

set -l stable_sock $HOME/.ssh/agent/current

# Publish: a shell holding a real forwarded socket adopts it as the current one.
if test -S "$SSH_AUTH_SOCK"; and test "$SSH_AUTH_SOCK" != $stable_sock
    mkdir -p (path dirname $stable_sock)
    ln -sfn "$SSH_AUTH_SOCK" $stable_sock

    # Reap sockets left behind by dead connections. The owning sshd pid is
    # encoded in the name, so liveness is exact; an age cutoff would instead
    # reap connections that are merely long-lived. A reused pid only ever
    # causes a dead socket to be kept, never a live one to be removed.
    set -l abandoned
    for sock in (string match -- 's.*.sshd.*' (path basename -- (path filter -- $HOME/.ssh/agent/*)))
        set -l pid (string replace -rf '.*\.sshd\.([0-9]+)\.[^.]+$' '$1' -- $sock)
        if test -n "$pid"; and not kill -0 $pid 2>/dev/null
            set -a abandoned $HOME/.ssh/agent/$sock
        end
    end
    test (count $abandoned) -gt 0; and rm -f $abandoned
end

# Consume: hand every descendant the stable path. Exported even while dangling
# (disconnected), since the next login repairs it in place.
if test -L $stable_sock
    set -gx SSH_AUTH_SOCK $stable_sock
end
