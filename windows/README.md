# Windows

This folder contains all the necessary files and steps to customize a new Windows 11 machine to be able to start building apps 🚀. This is done using a combination of [Windows Package Manager](https://learn.microsoft.com/windows/package-manager/winget/) (WinGet) [Configuration File](https://learn.microsoft.com/windows/package-manager/configuration/) (*configuration.dsc.yaml*) that will work with the WinGet command line interface (`winget configure --file [path: configuration.dsc.yaml]`) and manual tasks.

When run, the `configuration.dsc.yaml` file will install the following list of applications:

* Git for Windows

The `configuration.dsc.yaml` file will also apply the following changes on the target machine:

* Enable [Developer Mode](https://learn.microsoft.com/windows/apps/get-started/developer-mode-features-and-debugging)
* Enable Dark Mode
* ~~Enable the Windows Subsystem for Linux optional feature~~
* ~~Enable Virtual Machine Platform optional feature~~
* ~~Install [Ubuntu for WSL](https://learn.microsoft.com/windows/wsl/)~~
* Disable [User Account Control (UAC)](https://learn.microsoft.com/windows/security/application-security/application-control/user-account-control/)
* Set up a [Dev Drive](https://learn.microsoft.com/windows/dev-drive/) of 64Gb using a Virtual Hard Disk (VHD) with a per-user directory path location to store the Dev Drive
* Configure packages cache location on Dev Drive

> [!NOTE]
> The [PowerShell Desired State Configuration (DSC)](https://learn.microsoft.com/en-us/powershell/dsc/overview?view=dsc-2.0) that enable Windows optional features has been commented due to an error with winget configuration calls to DSC resource. For further details, see: <https://github.com/microsoft/winget-cli/issues/4264>.

## How do I use this folder? 🤔

To use this folder, simple follow the steps below with a version of this repo cloned in your local environment.

1. Download the `configuration.dsc.yaml` file to your computer.
1. Open your Windows Start Menu, search and launch "*Windows Terminal*" as Administrator.
1. Type the following: `winget configure --file [path: configuration.dsc.yaml]`

## References 📚

* [Intelligent Apps Dev Box Customization](https://github.com/microsoft/devcenter-examples/tree/main/devbox-intelligent-apps)
* [DSC Samples](https://github.com/microsoft/winget-dsc/tree/main/samples)
