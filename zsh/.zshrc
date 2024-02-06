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

# Source .zsh_prompt file from the same directory in which the current file resides
# if the file exists.
[[ -f ${ZDOTDIR}/.zsh_prompt ]] && source ${ZDOTDIR}/.zsh_prompt

# Enable GPG Key for SSH
unset SSH_AGENT_PID

if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY=$(tty)

# gpg-agent is a daemon to  manage secret (private) keys independently from any protocol.
# It's automatically started on demand by gpg, gpgsm, gpgconf, or gpg-connect-agent.
# However, as we want to use the included Secure Shell Agent we need to start the 
# agent if it isn't started already.
gpgconf --launch gpg-agent
