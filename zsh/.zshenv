# Sets XDG Base Directory Specification for the Apple standard paths.
# It defines the base directory relative to which user-specific files should be stored.
# https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
# https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/MacOSXDirectories/MacOSXDirectories.html
export XDG_CACHE_HOME="${HOME}/Library/Caches"
export XDG_CONFIG_HOME="${HOME}/Library/Application Support"
export XDG_DATA_HOME="${HOME}/Library/Application Support"
export XDG_STATE_HOME="${HOME}/Library/Application Support"

if [[ ! -d "$XDG_CACHE_HOME/zsh" ]]; then
    # Create a directory for Zsh cache, with the specified permissions:
    #   Owner: read, write, execute (7)
    #   Group: read (4)
    #   Others: read (4)
    mkdir -p -m 0744 "$XDG_CACHE_HOME/zsh"
fi

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZCACHEDIR="$XDG_CACHE_HOME/zsh"

# Disables macOS's "Save/Restore Shell State" feature and unify
# the terminal command history
if [[ "$OSTYPE" == darwin* ]]; then
    export SHELL_SESSIONS_DISABLE=1
fi

# Sets the default system editor.
export EDITOR="vim"
export VISUAL="vim"

# Disables the creation of the history file used by the Less command.
# Note: Since version 590 Less respects the XDG Base Directory Specification, however, it may
# take sometime to Apple updates the version bundled with macOS.
export LESSHISTFILE=-

# MAN colors
export LESS_TERMCAP_mb=$'e[1;35m'
export LESS_TERMCAP_md=$'e[1;36m'
export LESS_TERMCAP_me=$'e[0m'
export LESS_TERMCAP_se=$'e[0m'
export LESS_TERMCAP_so=$'e[1;44;33m'
export LESS_TERMCAP_ue=$'e[0m'
export LESS_TERMCAP_us=$'e[1;32m'

# Enables colored output for the ls command
export CLICOLOR=1
export LSCOLORS=gxfxexdxcxegedabagacad

# grep colors
export GREP_OPTIONS='--color=auto'

# Sets GnuPG configuration files directory.
# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html
if [[ -d "$XDG_DATA_HOME/gnupg" ]] ; then
    # To fix the "WARNING: unsafe permissions on homedir error"
    # corrent the permissons and access rights on the directory as follow:
    # chmod 600 ~/Library/Application Support/gnupg/*
    # chmod 700 ~/Library/Application Support/gnupg

    export GNUPGHOME="$XDG_DATA_HOME/gnupg"
fi

# Overrides the global location for .NET CLI settings and opt out of the telemetry feature.
export DOTNET_CLI_HOME="$XDG_DATA_HOME/Microsoft/Dotnet CLI"
export DOTNET_CLI_TELEMETRY_OPTOUT="true"

# Updates NuGet configuration for use XDG directories.
# https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders
export NUGET_PACKAGES="$XDG_DATA_HOME/NuGet/packages"
export NUGET_HTTP_CACHE_PATH="$XDG_CACHE_HOME/NuGet/v3-cache"
export NUGET_PLUGINS_CACHE_PATH="$XDG_CACHE_HOME/NuGet/plugins-cache"

# Add DOTNET Tools and the 'code' command in PATH env variable.
export PATH="$PATH:$DOTNET_CLI_HOME/.dotnet/tools"
export PATH="$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"