# Settings for https://github.com/franciscolourenco/done
#
# Deliberately `set -g`, not `set -U`: universal variables are written to
# ~/.local/share/fish/fish_variables, which Nix does not manage, so they would
# outlive their removal from this file and drift from the declared config.
set -g __done_min_cmd_duration 10000
set -g __done_notification_urgency_level low
