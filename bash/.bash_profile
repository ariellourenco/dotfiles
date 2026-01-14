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

# Customize the bash prompt (PS1)
__bash_prompt() {
  local green='\[\033[32m\]'
  local yellow='\[\033[33m\]'
  local red='\[\033[31m\]'
  local reset='\[\033[0m\]'

  # $? is a special Bash variable that holds the exit status of the last command (0 = success, non-zero = failure).
  local userpart='`export XIT=$? \
    && [ "$XIT" -ne "0" ] && echo -n "\[\033[30m\]➜ " || echo -n "\[\033[0m\]➜ "`'

  # local gitbranch='`\
  #     if [ "$(git config --get devcontainers-theme.hide-status 2>/dev/null)" != 1 ] && [ "$(git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
  #         export BRANCH="$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)"; \
  #         if [ "${BRANCH:-}" != "" ]; then \
  #             echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH:-}" \
  #             && if [ "$(git config --get devcontainers-theme.show-dirty 2>/dev/null)" = 1 ] && \
  #                 git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
  #                     echo -n " \[\033[1;33m\]✗"; \
  #             fi \
  #             && echo -n "\[\033[0;36m\]) "; \
  #         fi; \
  #     fi`'

  # PS1="${userpart} ${lightblue}\w ${gitbranch}${removecolor}\$ "
  # Show current path on one line, then arrow on the next
  PS1="${green}\w${reset}\n${userpart} "

  unset -f __bash_prompt
}
__bash_prompt
export PROMPT_DIRTRIM=4