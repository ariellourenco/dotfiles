      _                 _
     | |               | |
     | |__   ___    ___| |__  _ __ ___
     | '_ \ / _` \ / __| '_ \| '__/ __|
    _| |_) | (_| |\__  \ | | | | | (__
   (_)____.__/ \__,|___/_| |_|_|  \___|

This Bash configuration is designed to work seamlessly across both Git Bash (MSYS2) and Ubuntu/WSL environments. It provides a clean,
informative prompt inspired by [Cmder](https://cmderdev.github.io/cmder/), with rich git status integration and a consistent developer
experience on Windows and Linux alike.

## .bash_profile

The `.bash_profile` is the primary configuration file for interactive Bash sessions. It handles environment variables, the `PS1` prompt,
and sources supporting scripts. It's desined to be portable across diffrent enviroments, with conditional logic to improve unix tools on
Windows.

### Prompt (PS1)

The prompt is a two-line layout inspired by [Cmder](https://cmderdev.github.io/cmder/):

```bash
~/projects/dotfiles (main *%)
λ
```

- __Line 1__ — current working directory and git status (when inside a repository).
- __Line 2__ — the `λ` prompt symbol, yellow on success and red on a non-zero exit code.

#### Git Status

Git information is provided by `__git_ps1`, a function shipped with Git itself via `git-prompt.sh`. The file is sourced automatically from
the following locations, in order of preference:

| Path                                                   | Environment         |
|--------------------------------------------------------|---------------------|
| `$HOME/.config/git/git-prompt.sh`                      | User override (any) |
| `/usr/share/git/completion/git-prompt.sh`              | Git Bash / MSYS2    |
| `/usr/lib/git-core/git-sh-prompt`                      | Ubuntu / Debian     |
| `/usr/share/git-core/contrib/completion/git-prompt.sh` | Other distros       |

When `git-prompt.sh` is found, the following indicators are enabled:

| Variable                     | Symbol | Meaning                |
|------------------------------|--------|------------------------|
| `GIT_PS1_SHOWDIRTYSTATE`     | `*`    | Unstaged changes       |
| `GIT_PS1_SHOWDIRTYSTATE`     | `+`    | Staged changes         |
| `GIT_PS1_SHOWSTASHSTATE`     | `$`    | Stashed changes        |
| `GIT_PS1_SHOWUNTRACKEDFILES` | `%`    | Untracked files        |
| `GIT_PS1_SHOWUPSTREAM`       | `<`    | Behind upstream        |
| `GIT_PS1_SHOWUPSTREAM`       | `>`    | Ahead of upstream      |
| `GIT_PS1_SHOWUPSTREAM`       | `<>`   | Diverged from upstream |
| `GIT_PS1_SHOWUPSTREAM`       | `=`    | In sync with upstream  |

> [!NOTE]
> If `git-prompt.sh` is not found, the prompt falls back to a simpler custom implementation that shows the branch name and a `✗` indicator
> when there are uncommitted or untracked changes.

## References

- [Cmder — Console Emulator for Windows](https://cmderdev.github.io/cmder/)
- [git-prompt.sh source (Git for Windows)](https://github.com/git-for-windows/git/blob/main/contrib/completion/git-prompt.sh)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [Bash Prompt HOWTO](https://tldp.org/HOWTO/Bash-Prompt-HOWTO/)
