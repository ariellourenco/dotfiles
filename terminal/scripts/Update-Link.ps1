<#
.SYNOPSIS
Applies Solarized theme to Windows shortcut (.lnk) files.

.DESCRIPTION
Applications launched via a Windows shortcut file persists changes directly into the .lnk file. 
These information are stored as opaque blobs of data and are used by the Windows Console Host 
to override the default settings stored as values in [HKCU\Console\] registry key.

The Update-Link.ps1 script updates the Windows shortcut files replacing the default color pallete 
for the chosen theme.

.PARAMETER Path
The absolute path of the file (.lnk) containing the icon to be opened.

.PARAMETER Theme
Sets the theme of the application. Possible values: "Light", "Dark", "System".

.EXAMPLE
PS> .\Update-Link -Path "%USERPROFILE%\Desktop\Windows PowerShell.lnk"

.EXAMPLE
PS> .\Update-Link -Path "%USERPROFILE%\Desktop\Windows PowerShell.lnk\Windows PowerShell.lnk" -Theme "Dark"

.LINK
https://devblogs.microsoft.com/commandline/understanding-windows-console-host-settings/
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string][Alias('p')]$Path,

    [Parameter()]
    [ValidateSet('Light','Dark', 'System')]
    [string][Alias('t')]$Theme = 'System'
)

# Opens the specified file and initializes an object (Shell links) 
# from the file contents.
$lnk = & ("$PSScriptRoot\Get-Link.ps1") $Path

if(-not ($Theme -eq "System"))
{
    # Set Common Solarized Colors
    $lnk.ConsoleColors[0]="#002b36"
    $lnk.ConsoleColors[8]="#073642"
    $lnk.ConsoleColors[2]="#586e75"
    $lnk.ConsoleColors[6]="#657b83"
    $lnk.ConsoleColors[1]="#839496"
    $lnk.ConsoleColors[3]="#93a1a1"
    $lnk.ConsoleColors[7]="#eee8d5"
    $lnk.ConsoleColors[15]="#fdf6e3"
    $lnk.ConsoleColors[14]="#b58900"
    $lnk.ConsoleColors[4]="#cb4b16"
    $lnk.ConsoleColors[12]="#dc322f"
    $lnk.ConsoleColors[13]="#d33682"
    $lnk.ConsoleColors[5]="#6c71c4"
    $lnk.ConsoleColors[9]="#268bd2"
    $lnk.ConsoleColors[11]="#2aa198"
    $lnk.ConsoleColors[10]="#859900"

    # Set Light/Dark Theme-Specific Colors
    if ($Theme -eq "Dark") {
        $lnk.PopUpBackgroundColor=0xf
        $lnk.PopUpTextColor=0x6
        $lnk.ScreenBackgroundColor=0x0
        $lnk.ScreenTextColor=0x1
    } else {
        $lnk.PopUpBackgroundColor=0x0
        $lnk.PopUpTextColor=0x1
        $lnk.ScreenBackgroundColor=0xf
        $lnk.ScreenTextColor=0x6
    }
} else {
    # Set PowerShell default colors
    $lnk.ConsoleColors[0]="#000000"
    $lnk.ConsoleColors[8]="#808080"
    $lnk.ConsoleColors[2]="#008000"
    $lnk.ConsoleColors[6]="#eeedf0"
    $lnk.ConsoleColors[1]="#000080"
    $lnk.ConsoleColors[3]="#008080"
    $lnk.ConsoleColors[7]="#c0c0c0"
    $lnk.ConsoleColors[15]="#ffffff"
    $lnk.ConsoleColors[14]="#ffff00"
    $lnk.ConsoleColors[4]="#800000"
    $lnk.ConsoleColors[12]="#ff0000"
    $lnk.ConsoleColors[13]="#ff00ff"
    $lnk.ConsoleColors[5]="#012456"
    $lnk.ConsoleColors[9]="#0000ff"
    $lnk.ConsoleColors[11]="#00ffff"
    $lnk.ConsoleColors[10]="#00ff00"

    $lnk.PopUpBackgroundColor=0xf
    $lnk.PopUpTextColor=0x3
    $lnk.ScreenBackgroundColor=0x5
    $lnk.ScreenTextColor=0xf
}

$lnk.Save()

Write-Host "Updated $Path to $Theme"