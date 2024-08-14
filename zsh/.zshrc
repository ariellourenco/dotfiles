#              _
#             | |
#      _______| |__  _ __ ___
#     |_  / __| '_ \| '__/ __|
#    _ / /\__ \ | | | | | (__
#   (_)___|___/_| |_|_|  \___|
#
# This file is for interactive shell configurations such as setopt and unsetopt commands,
# load shell modules, set history options, change the prompt, set up zle and completion.
# It can also set any variables that are only used in the interactive shell (e.g. $LS_COLORS).

# Save command history
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=1000

# Load the prompt theme from ZDORDIR or HOME directory.
if [[ -f ${ZDOTDIR:-$HOME}/.zsh_prompt ]] ; then
  source ${ZDOTDIR:-$HOME}/.zsh_prompt
fi

# Updates zsh configuration files for use XDG directories.
[ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh

zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION

# Enable GPG Key for SSH
unset SSH_AGENT_PID

if [ ${gnupg_SSH_AUTH_SOCK_by:-0} -ne $$ ] ; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY=$(tty)

# gpg-agent is a daemon to  manage secret (private) keys independently from any protocol.
# It's automatically started on demand by gpg, gpgsm, gpgconf, or gpg-connect-agent.
# However, as we want to use the included Secure Shell Agent we need to start the
# agent if it isn't started already.
gpgconf --launch gpg-agent

# Make Vim follow XDG Base Directory specification
# After version 9.1.0327, Vim supports the XDG Base Directory specification and this code is not needed.
if [ -x "$(command -v vim)" ]; then
  [ "$(vim --clean -es + 'exec "!echo" has("patch-9.1.0327")' +q)" -eq 0 ] && \
    export VIMINIT="set nocp | source ${XDG_DATA_HOME:-$HOME/.config}/vim/vimrc"
fi