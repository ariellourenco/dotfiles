# Terminal Color Schemes

This folder contains files to setup a fancy experience on Windows across all its terminals options such as PowerShell, Linux 
Subsystem on Windows and Windows Terminal. 

Included are two important color schemes:

* Solarized-Dark - The default theme for all PowerShell instances
* Ubuntu - The default theme for Linux Subsystem (Ubuntu distro)

See the [Solarized](https://ethanschoonover.com/solarized) home page for screenshots and more details, as well as color schemes 
for other applications. For more themes see: [iTerm2-Color-Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes)

## Installation

### Update Registry for Linux on Windows (Ubuntu) and PowerShell

Import the `.reg` file of choice, e.g. `regedit /s solarized-dark.reg`.

This updates the registry defaults that are used for NEW shortcuts that start afresh, via `Windows+R`. It won't change existing 
shortcuts you may already created because they have their own color mapping.

### Update PowerShell shortcut .lnks

The easiest way to do this on Windows 10 is to click `Start`, then type in the command you want to change. When it appears in the 
list, right-click and select `Open file location`. This will open an Explorer window and show you the shortcut. Hold shift and 
right-click on the shortcut, then select `Copy as path`. Now open a PowerShell to the location of this project. 
In the PowerShell window use this command.

```PowerShell
Update-Link "<shortcut.lnk>" [dark|light]
```

The path to the shortcut.lnk is the same as you copied to your clipboard in the previous step. To easily paste it in Windows 10, 
just right-click on the window. If the path has spaces, you will want to wrap it in quotes, but if you followed the recommended 
way to use Copy as path, it will be done for you. If no theme is given, `Update-Link` will default to Solarized Dark. 

## Uninstall

### Registry for PowerShell

### PowerShell shortcut .lnks

Unfortunately, this is not the easiest to revert right now. One way, which is not recommended for casual users is to edit the 
Properties of an open window. From there, you can edit the colors manually, using the color table as a guide.
