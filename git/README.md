# Git Configuration

This document serves as a backup of my Git configuration settings. We leverage `include` and `includeIf` sections to include platform-specific directives as well as personal information from other sources to prevent sensitive information from leaking.

> The `include` and `includeIf` sections allow you to include config directives from another source. These sections behave identically with the exception that `includeIf` sections may be ignored if their condition does not evaluate to true; see "Conditional includes" below.
— Git - [git-config Documentation](https://git-scm.com/docs/git-config#_includes)

## Configuration Overview

### Including Personal Configurations

```text
[include]
    path = ./config.personal
```

This line includes a personal configuration file, allowing you to separate sensitive information from the main configuration.

### Conditional Inclusion

```text
[includeIf "gitdir/i:%(prefix)//mnt/c/"]
    path = %(prefix)//mnt/c/appdata/roaming/git/config.wsl
```

The `gitdir` condition ensures that the specified configuration is only loaded when working within certain directories, enhancing security and flexibility. The `/i` part configures the matching to be case-insensitive, and by ending the path with `/`, it automatically adds `/**`, thus matching all subdirectories.

> [!NOTE]
> By default, Git reads configuration options from [two user-wide configs](https://git-scm.com/docs/git-config#_configuration): `.gitconfig` in the home directory, and `$HOME/.config/git/config` unless `$XDG_CONFIG_HOME/git/config` is set which is the case here.

## Security Considerations

When managing Git configurations, be mindful of security implications related to storing sensitive information:

- Avoid storing passwords or tokens directly in your configuration files.
- Use tools like Git Credential Manager or SSH keys for authentication.
- Regularly audit your configurations for any sensitive data that may have been inadvertently included.
