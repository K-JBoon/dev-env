alias ls="ls -al --color"
alias du="du -h"
alias vi="nvim"
alias vim="nvim"
alias diff="colordiff"
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias df='df -H'
alias du='du -ch'

eval "$(starship init bash)"

export NVM_DIR="/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux new-session -A -s main
fi
