# Manually set the overall locale to en_US except the decimal dot, 
# the monetary format and the date/time which will be pt_BR.
export LC_ALL=en_US.UTF-8
export LC_MONETARY=pt_BR.UTF-8
export LC_NUMERIC=pt_BR.UTF-8
export LC_TIME=pt_BR.UTF-8

# For security reasons compinit also checks if the completion system would use files not owned by root
# or by the current user, or files in directories that are world- or group-writable or that are not owned by root 
# or by the current user. If such files or directories are found, compinit will ask if the completion system should really be used. 
# To avoid these tests and make all files found be used without asking, use the option -u, and to make compinit silently 
# ignore all insecure files and directories use the option -i. 
# In this case,by removing the write permissions for group/others for the files in cause (compaudit | xargs chmod go-w) 
# we mitigate this vulnerability.
autoload -Uz compinit
compinit -d ~/Library/Cache/zcompdump

# Colorizes the ls output with color and icons.
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

# Whether lsd is installed then override the ls alias.
# For more information: https://github.com/Peltoche/lsd
command -v lsd > /dev/null && alias ls='lsd --group-dirs first' && alias tree='lsd --tree'

# Colorize Man Pages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
export LESSHISTFILE=-

# Prompt
PROMPT=$'%F{%(#.blue.green)}┌──(%B%F{%(#.red.blue)}%n%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
#RPROMPT=$'%(?.. %? %F{red}%Bx%b%F{reset})%(1j. %j %F{yellow}%Bbg %b%F{reset}.)'

# ZSH Completion System
# https://thevaluable.dev/zsh-completion-guide-examples/
zstyle ':completion:*' verbose true

# Add DOTNET Tools and the 'code' command in PATH env variable.
export PATH="~/.dotnet/tools:$PATH"
export PATH="/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin:$PATH"

# Setup the terminal to use gpg-agent as the  SSH agent and make it starts with the terminal.
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)


