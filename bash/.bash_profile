#      _                 _
#     | |               | |
#     | |__   ___    ___| |__  _ __ ___
#     | '_ \ / _` \ / __| '_ \| '__/ __|
#    _| |_) | (_| |\__  \ | | | | | (__
#   (_)____.__/ \__,|___/_| |_|_|  \___|
#
# This file is used for interactive shell configurations. It includes:
# - Environment variables definitions and shell options
# - Aliases and functions definitions
# - Prompt (PS1) customizations
# - Command completion configuration and history behavior
# - Loading additional scripts or tools for the interactive shell

export XDG_CONFIG_HOME="$HOME/.config"

# This file is designed to work well with both MSYS2 and WSL. However, it is important to note that
# MSYS2 is a collection of Unix tools and libraries, it follows standard Unix conventions
# by using the `$HOME` or `$HOME/.config` directory to store user configuration files.
# In some cases, native Windows programs that are minimally ported from Unix write configuration
# files to `%USERPROFILE%\.appname` or `%USERPROFILE%\.config\appname`. To be a better Windows citizenship,
# we set the `$XDG_CONFIG_HOME` environment variable to support standard Windows paths, such as `%AppData%`.
case "$APPDATA" in *\\*) APPDATA="$(cygpath -au "$APPDATA")";; esac
test -d "$XDG_CONFIG_HOME" || test ! -d "$APPDATA" || {
  XDG_CONFIG_HOME="$APPDATA"
}

# Sets GnuPG configuration files directory.
# https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"