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

# Source git-prompt.sh for rich __git_ps1 support.
# Tries common locations for Git Bash (MSYS2) and Ubuntu/WSL.
for __git_prompt_path in \
    "$HOME/.config/git/git-prompt.sh" \
    "/usr/share/git/completion/git-prompt.sh" \
    "/usr/lib/git-core/git-sh-prompt" \
    "/usr/share/git-core/contrib/completion/git-prompt.sh"; do
  [ -f "$__git_prompt_path" ] && { . "$__git_prompt_path"; break; }
done

unset __git_prompt_path

export GIT_PS1_SHOWDIRTYSTATE=1       # * unstaged, + staged
export GIT_PS1_SHOWSTASHSTATE=1       # $ stashed changes
export GIT_PS1_SHOWUNTRACKEDFILES=1   # % untracked files
export GIT_PS1_SHOWUPSTREAM="auto"    # < behind, > ahead, <> diverged, = in sync

# Customize the bash prompt (PS1)
__bash_prompt() {
  local green='\[\033[32m\]'
  local yellow='\[\033[33m\]'
  local cyan='\[\033[0;36m\]'
  local red='\[\033[31m\]'
  local reset='\[\033[0m\]'

  # $? is a special Bash variable that holds the exit status of the last command (0 = success, non-zero = failure).
  # Uses λ (lambda) as the prompt symbol, matching Cmder's visual style.
  local userpart='`XIT=$? \
    && [ "$XIT" -ne "0" ] && echo -n "\[\033[31m\]λ " || echo -n "\[\033[33m\]λ "`'

  # Use __git_ps1 (from git-prompt.sh) when available for richer git status:
  # Falls back to a simpler custom implementation otherwise.
  local gitbranch
  if declare -f __git_ps1 > /dev/null; then
    gitbranch='\[\033[0;36m\]`__git_ps1 "(%s) "`\[\033[0m\]'
  else
    gitbranch='`\
        export BRANCH="$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
            || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)"; \
        if [ "${BRANCH:-}" != "" ]; then \
            echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH}" \
            && if [ -n "$(git --no-optional-locks status --porcelain 2>/dev/null)" ]; then \
                echo -n " \[\033[1;33m\]✗"; \
            fi \
            && echo -n "\[\033[0;36m\]) "; \
        fi`'
  fi

  # Line 1: working directory with optional git branch/status info
  # Line 2: λ prompt symbol (yellow on success, red on error)
  PS1="${green}\w${reset} ${gitbranch}\n${userpart}${reset}"

  unset -f __bash_prompt
}

__bash_prompt
export PROMPT_DIRTRIM=4

# Print a blank line before each prompt except the very first one.
__bash_first_prompt=1

PROMPT_COMMAND='[ -z "$__bash_first_prompt" ] && printf "\n" || unset __bash_first_prompt'