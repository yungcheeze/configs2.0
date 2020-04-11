bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

alias to-clip="xclip -selection c"

export EDITOR="emacsclient --tty --socket-name=terminal"
export SUDO_EDITOR="$EDITOR"
export ALTERNATE_EDITOR=""
export VISUAL="emacsclient --create-frame --socket-name=gui"
alias e="$VISUAL"                      # used to be "emacs -nw"
alias et="$EDITOR"                      # used to be "emacs -nw"

# configure less (https://www.topbug.net/blog/2016/09/27/make-gnu-less-more-powerful/)
export LESS='--ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# HSTR configuration - add this to ~/.bashrc
alias hh=hstr                    # hh to be alias for hstr
export HSTR_CONFIG=hicolor       # get more colors
shopt -s histappend              # append new history items to .bash_history
export HISTCONTROL=ignorespace   # leading space hides commands from history
export HISTFILESIZE=100000        # increase history file size (default is 500)
export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
# ensure synchronization between Bash memory and history file
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
# if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
if [[ $- =~ .*i.* ]]; then bind '"\er": "\C-a hstr -- \C-j"'; fi


source /home/ucizi/.config/broot/launcher/bash/br

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

if [ "$TERM" != "linux" ]; then
    source ~/configs2.0/pureline/pureline ~/configs2.0/pureline.conf
fi


source ~/configs2.0/commacd.sh

fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi
source "$fasd_cache"
unset fasd_cache
alias fcd="fasd_cd -id"
