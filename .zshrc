# Zsh ships with a framework for getting information from version control
# systems, called vcs_info, and a tab-completion library for Git.
autoload -Uz compinit && compinit
autoload -Uz colors && colors

# Allow substitutions and expansions in the prompt, necessary for
# using a single-quoted $vcs_info_msg_0_ in PS1 and PROMPT.
setopt promptsubst

# Load vcs_info to display information about version control repositories.
autoload -Uz vcs_info

# Check the repository for changes so they can be used in %u/%c
# This comes with a speed penalty for bigger repositories.
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true

# Set values for the follow styles in all contexts.
zstyle ':vcs_info:*' unstagedstr '!'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[yellow]%}%{$fg[magenta]%}%b%{$fg[red]%}%m%u%c%{$fg[blue]%})"
zstyle ':vcs_info:git*+set-message:*' hooks git-st  git-untracked

# Use the zsh hook function precmd to run the vcs_info function 
# right before we display the prompt.
precmd_vcs_info() { vcs_info }
precmd_functions+=(precmd_vcs_info)

# Display the existence of files not yet know to VCS (untracked files).
# The marker (?) is shown if there are untracked files in repository.
+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep -q '^?? ' 2> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[staged]+='?'
    fi
}

# Show +N/-N when the local branch is ahead-of or behind remote HEAD.
# Make sure to have added misc to your 'formats':  %m
+vi-git-st(){
    local ahead behind
    local -a gitstatus

    # Exit early in case the worktree is on a detached HEAD
    git rev-parse ${hook_com[branch]}@{upstream} >/dev/null 2>&1 || return 0

    local -a ahead_and_behind=(
        $(git rev-list --left-right --count HEAD...${hook_com[branch]}@{upstream} 2>/dev/null)
    )

    ahead=${ahead_and_behind[1]}
    behind=${ahead_and_behind[2]}

    (( $ahead )) && gitstatus+=( "+${ahead}" )
    (( $behind )) && gitstatus+=( "-${behind}" )

    hook_com[misc]+=${(j:/:)gitstatus}
}

PROMPT+="\$vcs_info_msg_0_ "

export SSH_AUTH_SOCK=`gpgconf --list-dirs agent-ssh-socket`
export GPG_TTY=$(tty)
