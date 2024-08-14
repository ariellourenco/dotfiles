               _
              | |
       _______| |__  _ __ ___
      |_  / __| '_ \| '__/ __|
     _ / /\__ \ | | | | | (__
    (_)___|___/_| |_|_|  \___|

This repository includes greatly customized zsh with antibody featuring auto-completion, syntax highlighting, autopair and a Pure Powerlevel10k theme. Also, a one-liner install leverages Brew and mackup to setup an entire macOS environment.

## Requeriments

Before we proceed, ensure you have [Nerd Font](https://www.nerdfonts.com) installed and used in your terminal. [Cascadia Code](https://github.com/microsoft/cascadia-code) is a popular choice and it now [supports Nerd Font glyphs](https://devblogs.microsoft.com/commandline/cascadia-code-2404-23/) by default. To verify that you have everything set up correctly, run the following command in your terminal:

```bash
echo -e "\xee\x82\xa0"
```

If you see a git branch glyph as output, it means your terminal is successfully rendering the Nerd Font glyphs. If not, double-check your font settings and ensure you have installed a compatible Nerd Font.

## ZSHENV

> Home is where you're supposed to be most comfortable in. It is your place of refuge, and a sanctum from the mess and chaos of the outside world. It is where you have complete liberty over everything: what you do, when you do things, how you do them, what things you have. It is where these things are supposed to be where you want them, and how you want them to be. <br />
by _Sharadh Rajaraman_

The **.zshenv** file provided as part of this repository has the main goal of keep your `$HOME` clean and tidy. It defines a set environment variables that are available to all shell instances, such as `$PATH`, `$EDITOR` and other several environment variables that attempt to standardise dot-files and dot-directories based on the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

The table below depicts the most important XDG environment variables used across *nix systems and its counterparts values on MacOS:

| **Variable**       | **Default value**    | **OSX**                         | **Details**                                                                                                                                                      |
|--------------------|----------------------|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `$XDG_CACHE_HOME`  | `$HOME/.cache`       | `~/Library/Caches`              | Caches limited to single runs of a program, but can extend to persistent caches, e.g. user-installed package manager caches for `pip`, `pacman`, `vcpkg`, etc.   |
| `$XDG_CONFIG_HOME` | `$HOME/.config`      | `~/Library/Preferences`         | User-specific configuration files, including `.*rc` and `.*env` files; VS Code `settings.json`.                                                                  |
| `$XDG_DATA_HOME`   | `$HOME/.local/share` | `~/Library/Application Support` | User-specific data files; e.g. program databases, caches that persist through multiple program runs, search indices, 'Trash' directory for desktop environments. |
| `$XDG_STATE_HOME`  | `$HOME/.local/state` | `~/Library/Application Support` | User-specific state files, such as terminal history files.                                                                                                       |

> [!NOTE]
> These mappings seem pretty reasonable but they aren't exact. Some data may be more appropriate for `~/Library/My App` or some configuration file for `~/Library/Application Support`, for instance, the [choice](https://pkg.go.dev/os#UserConfigDir) made by the `OS` package in `golang` maps `$XDG_CONFIG_HOME` to `~/Library/Application Support`. For further details, see: [Mac OS Directories](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/MacOSXDirectories/MacOSXDirectories.html).

Unfortunately, although the [XDG Base Directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) defines clear locations where configuration files should be placed and, as a user, you expect that softwares adhere to these specifications, the truth is that there are a myriad of programs that does not respect the specification and writes data to a non-canonical location in the user's home directory.

The Arch Wiki has a [list of programs](https://wiki.archlinux.org/title/XDG_Base_Directory#Support) that are XBD-compliant by default and those with hard-coded non-XBD paths. The latter two lists combined is almost twice as long as the compliant list, and includes some very prominent *nix-first software like Bash, ZSH, and Firefox.

> [!NOTE]
> Starting with version [9.1.0327](https://github.com/vim/vim/commit/c9df1fb35a1866901c32df37dd39c8b39dbdb64a), [Vim has incorporated support for the XDG Base Directory Specification](https://github.com/vim/vim/pull/14182).
This is a significant development, but it may take some time for Apple to integrate it. In the meantime, this repository implements a slightly different [workaround](https://jorenar.com/blog/vim-xdg) suggested by Jorengarenar.
For further details, see: [https://github.com/vim/vim/blob/master/runtime/doc/starting.txt](https://github.com/vim/vim/blob/master/runtime/doc/starting.txt)

Below there is a list of open issues that worth to keep an eye on if you are a .NET developer :rocket::

| **Application**         | **Path**                          | **Discussion**        |
|-------------------------|-----------------------------------|-----------------------|
| .NET Runtime            | `~/.microsoft/`                   | [1](https://github.com/dotnet/runtime/issues/101012)            |
| ASP.NET Core            | `~/.aspnet/`                      | [2](https://github.com/dotnet/aspnetcore/issues/43278)          |
| Mono                    | `~/.mono/`                        | [3](https://github.com/mono/mono/pull/12764)                    |
| C# Dev Kit for VS Code  | `~/.ServiceHub/`                  | [4](https://github.com/microsoft/vscode-dotnettools/issues/514) |
| Visual Studio Code      | `~/.vscode[-variant]/extensions/` | [5](https://github.com/microsoft/vscode/issues/3884)            |

> [!IMPORTANT]
> By default, Git reads configuration options from [two user-wide configs](https://git-scm.com/docs/git-config#_configuration): `.gitconfig` in the home directory, and `$HOME/.config/git/config` unless `$XDG_CONFIG_HOME/git/config` is set. Since neither of these are Windows-native directories, [Git for Windows now looks for Git/config in the AppData directory](https://github.com/git-for-windows/git/pull/5030), unless `$HOME/.config/git/config` exists. Worth note that this feature isn't enable by default, the presence of the file in one of the specified directories as a cue that the user wants to use this feature, therefore, we need to create it manually.

## References

- [$HOME, Not So Sweet $HOME](https://gist.github.com/sharadhr/39b804236c1941e9c30d90af828ad41e)
- [Dotfile madness](https://0x46.net/thoughts/2019/02/01/dotfile-madness/)
- [Dotfiles Are Everywhere. We've Lost Control Of Our Home Directories!](https://www.youtube.com/watch?v=AFtfpluqv14)
