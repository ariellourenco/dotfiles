# Manually set the overall locale to en_US except the decimal dot, 
# the monetary format and the date/time which will be pt_BR.
export LC_ALL=en_US.UTF-8
export LC_MONETARY=pt_BR.UTF-8
export LC_NUMERIC=pt_BR.UTF-8
export LC_TIME=pt_BR.UTF-8

# Add DOTNET Tools and the 'code' command in PATH env variable.
export PATH="~/.dotnet/tools:$PATH"
export PATH="/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin:$PATH"

# Setup the terminal to use gpg-agent as the  SSH agent and make it starts with the terminal.
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)
