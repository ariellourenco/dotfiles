# Set XDG Base Directory Specification for the Apple standard paths.
# It defines the base directory relative to which user-specific files should be stored.
# https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
# https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/MacOSXDirectories/MacOSXDirectories.html
export XDG_CACHE_HOME="${HOME}/Library/Caches"
export XDG_CONFIG_HOME="${HOME}/Library/Preferences"
export XDG_DATA_HOME="${HOME}/Library/Application Support"
export XDG_STATE_HOME="${HOME}/Library/Application Support"

# Sets ZSH configuration directory.
if [[ -d "$XDG_CONFIG_HOME/zsh" ]] ; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

# Sets GnuPG configuration files directory.
# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html
if [[ -d "$XDG_DATA_HOME/gnupg" ]] ; then
    # To fix the "WARNING: unsafe permissions on homedir error" 
    # corrent the permissons and access rights on the directory as follow:
    # chmod 600 ~/Library/Application Support/gnupg/*
    # chmod 700 ~/Library/Application Support/gnupg 

    export GNUPGHOME="$XDG_DATA_HOME/gnupg"
fi

# Override the global location for .NET CLI settings and opt out of the telemetry feature.
export DOTNET_CLI_HOME="$XDG_DATA_HOME/Microsoft/Dotnet CLI"
export DOTNET_CLI_TELEMETRY_OPTOUT="yes"

# Updates NuGet configuration for use XDG directories.
# https://learn.microsoft.com/en-us/nuget/consume-packages/managing-the-global-packages-and-cache-folders
export NUGET_PACKAGES="$XDG_DATA_HOME/NuGet/packages"
export NUGET_HTTP_CACHE_PATH="$XDG_CACHE_HOME/NuGet/v3-cache"
export NUGET_PLUGINS_CACHE_PATH="$XDG_CACHE_HOME/NuGet/plugins-cache"