abbr --add -- python python3
abbr --add -- docker podman
abbr --add -- gs 'git status'
abbr --add -- gpf 'git push --force-with-lease'
abbr --add -- cg 'cargo build'
abbr --add -- ct 'cargo test'
abbr --add -- cr 'cargo run'
abbr --add -- ff fastfetch
abbr --add -- ghostscript /usr/bin/ghostscript
abbr --add -- livecrates "cargo watch -s 'cargo doc && browser-sync start --ss target/doc -s target/doc --directory --no-open'"

# Replace ls with eza
alias ls='eza -al --color=always --group-directories-first --icons=auto' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons=auto' # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons=auto' # long format
alias lt='eza -aT --color=always --group-directories-first --icons=auto' # tree listing
alias l.="eza -a | grep -e '^\.'" # show only dotfiles

# Common use
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"
