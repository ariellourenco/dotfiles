# Git Configuration

Git provides a myriad of configuration options that help developers optimize their environments and boost productivity. However, working with different Git cloud providers, such as [GitHub](https://github.com) or [GitLab](https://gitlab.com), or across various operating systems can create challenges where a single Git configuration file becomes impractical. The git configuration in this project is designed to maintain a clean separation between common settings and personal, sensitive information.

This document provides information about the strategy used to organize my Git configuration files.

## Configuration Overview

### Naming Convention

As with other naming guidelines, the goal when naming configuration files is creating sufficient clarity for the user to immediately know what the content of the file is likely to be. The following template specifies the general rule used:

```text
(config|.gitconfig).(<Platform>|<Git Provider>)[.(personal|work)]
```

The following are examples:

`config.windows` `.gitconfig.github.personal`

### Including Personal Configurations

> The `include` and `includeIf` sections allow you to include config directives from another source. These sections behave identically, with the exception that `includeIf` sections may be ignored if their condition does not evaluate to true; see "Conditional includes" below.
— Git - [git-config Documentation](https://git-scm.com/docs/git-config#_includes)

To maintain a clean separation between common settings and personal, sensitive information we leverage the `include` directive in the [main config](config#L31) file, which references an additional personal configuration file. The personal configuration file, such as `config.personal`, is intentionally excluded from the repository's version control to protect private data like email addresses, signing keys, and other sensitive details that should not be publicly exposed.

In addition to personal configurations, the project accommodates platform-specific settings through the inclusion of system-specific config files like `config.windows` or `config.wsl`. These files contain environment-dependent configurations tailored for different operating systems or environments, ensuring Git behaves correctly regardless of the host machine. By including these files conditionally, the [main git configuration](config) remains unchanged, while allowing the user to seamlessly adapt settings to their current machine without affecting others.

#### Personal Configuration Sample

```text
[include]
	path = config.windows
[user]
    email = youremail@example.com
    signingkey = 36264D8005D951D8
```

> [!NOTE]
> By default, Git reads configuration options from [two user-wide configs](https://git-scm.com/docs/git-config#_configuration): `.gitconfig` in the home directory, and `$HOME/.config/git/config` unless `$XDG_CONFIG_HOME/git/config` is set. Since neither of these are Windows-native directories, [Git for Windows now looks for Git/config in the AppData directory](https://github.com/git-for-windows/git/pull/5030), unless `$HOME/.config/git/config` exists. Worth note that this feature isn't enable by default, the presence of the file in one of the specified directories as a cue that the user wants to use this feature, therefore, we need to create it manually.

## Security Considerations

When managing Git configurations, be mindful of security implications related to storing sensitive information:

- **Avoid Direct Storage**: Do not versioning passwords or tokens stored in your configuration files.
- **Use Secure Authentication**: Utilize tools like [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager) or SSH keys for authentication.
- **Regular Audits**: Regularly audit your configurations for any sensitive data that may have been inadvertently included. Sensitive data can include API tokens, private keys, or personal information.

By following these guidelines, you can effectively manage your Git configurations across different environments while maintaining security and organization.
