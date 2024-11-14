# https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
# http://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# http://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

# Ensure that the terminal is in application mode when Zsh's line editor (zle) is active.
# Check if the $terminfo, which is a Zsh associative array that holds terminal capabilities, has
# the smkx (Start Keypad eXtended) and rmkx (Revert Keypad eXtended). If both are present,
# it’s safe to enable application mode when zle is active.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# Use emacs key bindings
bindkey -e

# [Home] - Go to beginning of line
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -M emacs '^[[H' beginning-of-line
  bindkey -M viins '^[[H' beginning-of-line
  bindkey -M vicmd '^[[H' beginning-of-line
fi

# [End] - Go to end of line
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -M emacs '^[[F' end-of-line
  bindkey -M viins '^[[F' end-of-line
  bindkey -M vicmd '^[[F' end-of-line
fi

# [Delete] - Delete forward
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -M emacs "${terminfo[kdch1]}" delete-char
  bindkey -M viins "${terminfo[kdch1]}" delete-char
  bindkey -M vicmd "${terminfo[kdch1]}" delete-char
else
  bindkey -M emacs "^[[3~" delete-char
  bindkey -M viins "^[[3~" delete-char
  bindkey -M vicmd "^[[3~" delete-char
fi

# [Ctrl-Delete] - Delete whole forward-word
bindkey -M emacs '^[[3;5~' kill-word
bindkey -M viins '^[[3;5~' kill-word
bindkey -M vicmd '^[[3;5~' kill-word

# [Option-Left Arrow] - Move backward one word
bindkey -M emacs '^[[3;5D' backward-word
bindkey -M viins '^[[3;5D' backward-word
bindkey -M vicmd '^[[3;5D' backward-word

# [Option-Right Arrow] - Move forward one word
bindkey -M emacs '^[[3;5C' forward-word
bindkey -M viins '^[[3;5C' forward-word
bindkey -M vicmd '^[[3;5C' forward-word

# [Shift-Tab] - Move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
  bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
  bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
fi

# [Ctrl-r] - Search backward incrementally for a specified string.
# The string may begin with ^ to anchor the search to the beginning of the line.
bindkey '^r' history-incremental-search-backward

# [Space] - don't do history expansion
bindkey ' ' magic-space
