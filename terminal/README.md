# Terminal

This folder contains files to setup a fancy experience on Windows across all its terminal options such as PowerShell, Linux Subsystem on Windows and Windows Terminal. This repository and its files was inspired by the work done by Neil Pankey, Ryan Beesley, Scott Hanselman, Russell West, and Paul Hampson in this [repository](https://github.com/neilpa/cmd-colors-solarized). 

## Color Schemes

Included are three color schemes:

* Solarized Light
* Solarized Dark - The default theme for all PowerShell instances
* Ubuntu - The default theme for Linux Subsystem (Ubuntu distro)

For more details and screenshots, as well as color schemes for other applications see the [Solarized](https://ethanschoonover.com/solarized) home page. The [ColorTool](https://github.com/Microsoft/Terminal/tree/master/src/tools/ColorTool) is also a great tool to create and explore new color schemes and it also  includes support for [iTerm](https://github.com/mbadolato/iTerm2-Color-Schemes) themes!

## Installation

### Update Registry for PowerShell

Import the `.reg` file of choice, e.g. `regedit /s Solarized-Dark.reg`.

This updates the registry defaults that are used for NEW shortcuts that start afresh, via `Windows+R`. It won't change existing 
shortcuts you may already created because they have their own color mapping stored as opaque blobs of data directly into the .lnk file.

>[!WARNING]
>
> Editing the registry carries risks, as a single mistake can lead to system instability. Therefore, it is essential to back up the registry and create a restore point before proceeding with the following steps.

### Update PowerShell shortcut .lnks

The easiest way to do this on Windows 10 is to click `Start`, then type in the command you want to change. When it appears in the list, `right-click` and select `Open file location`. This will open an Explorer window and show you the shortcut. Hold shift and right-click on the shortcut, then select `Copy as path`. Now open a PowerShell to the location of this project.

In the PowerShell window use this command.

```PowerShell
Update-Link "<shortcut.lnk>" [Light|Dark|System]
```

The path to the shortcut.lnk is the same as you copied to your clipboard in the previous step. To easily paste it in Windows 10, 
just right-click on the window. If the path has spaces, you will want to wrap it in quotes, but if you followed the recommended 
way to use Copy as path, it will be done for you. If no theme is given, `Update-Link` will default to Solarized Dark. 

## Uninstall

### Registry for PowerShell

The file `Defaults.reg` is provided to restore the command prompt colors back to their shipping defaults. The registry settings have been checked for versions of Windows back to at least Windows 7 and the values are the same. To restore the defaults, open the `regedit` and delete the following keys:

* `[HKEY_CURRENT_USER\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe]`
* `[HKEY_CURRENT_USER\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe]`

Then import the .reg file the same way as you applied it previously, `regedit /s Defaults.reg`.

### PowerShell shortcut .lnks

To restore the shortcut file defaults use the follow command.

```PowerShell
Update-Link "<shortcut.lnk>" System
```

## Side Notes

There are a bunch of great modules out there that can help boost your experience using PowerShell such as [PSReadLine](https://github.com/PowerShell/PSReadLine), which makes PowerShell behave like zsh, that is my favorite shell in GNU/Linux. It gives you substring history search, incremental history search, and awesome tab-completion. Down below, some other modules that compose my Powershell customizations:

* [Get-ChildItemColor](https://github.com/joonro/Get-ChildItemColor)
* [PackageManagement (OneGet)](https://github.com/OneGet/oneget)
* [PSReadLine](https://github.com/PowerShell/PSReadLine)
* [Termnal-Icons](https://github.com/devblackops/Terminal-Icons)
* [posh-git](https://github.com/dahlbyk/posh-git)
