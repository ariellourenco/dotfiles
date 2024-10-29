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

# Sets the history file path and options.
# The values chosen here are the recoomended value to have a substantial history without overly impacting performance.
HISTFILE=${ZCACHEDIR:-$HOME}/.zsh_history  # History filepath
HISTSIZE=2000                                 # Maximum number of commands that are stored in memory during a shell session.
SAVEHIST=1000                                 # Maximum number of commands that are saved in the history file when the shell exits.

# Zsh history command configuration
setopt append_history           # Append history to the history file
setopt extended_history         # Record timestamp of command in HISTFILE
setopt hist_expire_dups_first   # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups         # Ignore duplicated commands history list
setopt hist_ignore_space        # Ignore commands that start with space
setopt hist_reduce_blanks       # Remove superfluous blanks before recording command
setopt hist_verify              # Show command with history expansion to user before running it
setopt share_history            # Share command history data between sessions

# Zsh changing/making/removing directory
setopt auto_cd                  # Change to directory without cd command
setopt auto_pushd               # Push directory into directory stack after cd
setopt no_case_glob             # Case-insensitive globbing
setopt correct                  # Auto-correct commands
setopt extended_glob            # Enable extended globbing – ls *(a|b)*file
setopt pushd_ignore_dups        # Do not push duplicated directories into directory stack
setopt pushdminus               # Swap the top two directories when using cd -

# Extends the zsh capabilities by sourcing external configuration files.
[ -f "${ZDOTDIR}/modules/completion.zsh" ] && source "${ZDOTDIR}/modules/completion.zsh"

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
