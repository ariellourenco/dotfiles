################################################################################
## File: Install-Dotfiles.ps1
## Desc: Installs dotfiles for Windows environment by symlinking configuration files.
## Author: Ariel Lourenço <ariellourenco@users.noreply.github.com>
################################################################################

#Requires -RunAsAdministrator
#Requires -Version 7.0

[CmdletBinding()]
param()

# Global configuration
$script:Config = @{
    DotfilesPath = "D:\dotfiles"
}

function Set-WindowsTerminalSettings {
    $remoteTerminalSettings = "$($script:Config.DotfilesPath)\windows\settings.json"
    $windowsTerminalSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (Test-Path $windowsTerminalSettings) {
        Write-Verbose -Message "Windows Terminal (Store version) detected."

        try {
            # Only back up if not a symbolic link
            if (-not (Get-Item -Path $windowsTerminalSettings).LinkType) {
                # Backup current settings with timestamp
                $backupPath = "$windowsTerminalSettings.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
                Copy-Item -Path $windowsTerminalSettings -Destination $backupPath -Force

                Write-Verbose -Message "Backed up the current Windows Terminal settings."

                # Remove the original settings file before creating the symlink
                Remove-Item -Path $windowsTerminalSettings -Force
            }

            # Create the symlink
            New-Item -ItemType SymbolicLink -Path $windowsTerminalSettings -Target $remoteTerminalSettings -Force

            Write-Verbose -Message "Symlink created from $remoteTerminalSettings to $windowsTerminalSettings"
            return $true
        } catch {
            Write-Warning -Message "💥Failed to create symlink. Rolling back to the backup."

            if (-Not (Test-Path $windowsTerminalSettings) -and (Test-Path $backupPath)) {
                Copy-Item -Path $backupPath -Destination $windowsTerminalSettings -Force
                Write-Verbose -Message "Rollback succeeded, original settings restored." -Verbose
            } else {
                Write-Error -Message "Rollback failed. Manual intervention required."
            }

            return $false
        }
    }

    Write-Warning -Message "Windows Terminal settings file not found. Skipping symlink creation."
    return $false
}

# installation function junction
function Start-Installation {
    $steps = @(
        {Set-WindowsTerminalSettings}
    )

    $successful = 0
    $total = $steps.Count

    for ($i = 0; $i -lt $steps.Count; $i++) {
        $stepNumber = $i + 1
        Write-Progress -Activity "Running..." -Status "Step $stepNumber of $total" -PercentComplete (($stepNumber / $total) * 100)

        if (& $steps[$i]) {
            $successful++
        } else {
            #
        }
    }

    Write-Progress -Activity "Running..." -Completed

    if ($successful -eq $total) {
        return $true
    } else {
        Write-Host ""
        Write-Host "Installation completed with $($total - $successful) failures. Check log for details." -ForegroundColor Yellow
        return $false
    }
}

# Script entry point
try {
    Clear-Host
    Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "    https://github.com/ariellourenco/dotfiles                    " -ForegroundColor yellow
    Write-Host "-----------------------------------------------------------------" -ForegroundColor Yellow

    $success = Start-Installation

    if ($success) {
        Write-Host ""
        Write-Host " ✔️ Windows Terminal settings symlinked successfully." -ForegroundColor Green
        Write-Host ""

        exit 0
    } else {
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "Installation failed with unexpected error: " -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}