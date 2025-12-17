using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Import necessary modules
Import-Module -Name CompletionPredictor
Import-Module -Name posh-git
Import-Module -Name Terminal-Icons

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Disable oh-my-posh when running in VSCode and Visual Studio integrated terminals
    if ($env:TERM_PROGRAM -ne 'vscode' -and $env:VSAPPIDNAME -ne 'devenv.exe') {
        oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/ariellourenco/dotfiles/main/windows/mytheme.omp.json' | Invoke-Expression
    }
}

# Configure the PSReadLine module
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 100
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

if ($PSVersionTable.PSEdition -eq 'Core') {
    # Windows PowerShell does not support predictive suggestion feature because the console
    # output does not support virtual terminal processing or it's redirected.
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
}

# Configure key handlers for history search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Key handler for capturing the screen
Set-PSReadLineKeyHandler -Chord 'Ctrl+d,Ctrl+c' -Function CaptureScreen

# Key handler for showing command history in Out-GridView
Set-PSReadLineKeyHandler -Key F7 `
    -BriefDescription History `
    -LongDescription 'Show command history' `
    -ScriptBlock {
        $pattern = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)

        if ($pattern) {
            $pattern = [regex]::Escape($pattern)
        }

        $history = [System.Collections.ArrayList]@(
            $last = ''
            $lines = ''
            foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
                if ($line.EndsWith('`')) {
                    $line = $line.Substring(0, $line.Length - 1)
                    $lines = if ($lines) {
                        "$lines`n$line"
                    } else {
                        $line
                    }
                    continue
                }

                if ($lines) {
                    $line = "$lines`n$line"
                    $lines = ''
                }

                if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                    $last = $line
                    $line
                }
            }
        )

        $history.Reverse()

        $command = $history | Out-GridView -Title History -PassThru

        if ($command) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
        }
    }

# Key handler for saving a command in history without executing
Set-PSReadLineKeyHandler -Key Alt-w `
    -BriefDescription SaveInHistory `
    -LongDescription "Save current line in history but do not execute" `
    -ScriptBlock {
        param($key, $arg)

        $line = $null
        $cursor = $null

        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    }

#region Smart Insert/Delete

# Key handler for smart insertion of quotes
Set-PSReadLineKeyHandler -Key '"',"'" `
    -BriefDescription SmartInsertQuote `
    -LongDescription "Insert paired quotes if not already on a quote" `
    -ScriptBlock {
        param($key, $arg)

        $quote = $key.KeyChar

        $selectionStart = $null
        $selectionLength = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        # If text is selected, just quote it without any smarts
        if ($selectionStart -ne -1) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $selectionStart,
                $selectionLength,
                $quote + $line.SubString($selectionStart, $selectionLength) + $quote
            )
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
            return
        }

        $ast = $null
        $tokens = $null
        $parseErrors = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

        function FindToken {
            param($tokens, $cursor)

            foreach ($token in $tokens) {
                if ($cursor -lt $token.Extent.StartOffset) { continue }
                if ($cursor -lt $token.Extent.EndOffset) {
                    $result = $token
                    $token = $token -as [StringExpandableToken]
                    if ($token) {
                        $nested = FindToken $token.NestedTokens $cursor
                        if ($nested) { $result = $nested }
                    }

                    return $result
                }
            }
            return $null
        }

        $token = FindToken $tokens $cursor

        # If we're on or inside a quoted string token, handle accordingly
        if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
            if ($token.Extent.StartOffset -eq $cursor) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
                return
            }

            if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
                return
            }
        }

        if ($null -eq $token -or
            $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
            if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
            } else {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            }
            return
        }

        if ($token.Extent.StartOffset -eq $cursor) {
            if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or
                $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
                $end = $token.Extent.EndOffset
                $len = $end - $cursor
                [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                    $cursor,
                    $len,
                    $quote + $line.SubString($cursor, $len) + $quote
                )
                [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
                return
            }
        }

        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
    }

#endregion Smart Insert/Delete

# Sometimes you want to get a property or invoke a member on what you've entered so far,
# but you need parentheses to do that. This binding will help by putting parentheses
# around the current selection, or if nothing is selected, the whole line.
Set-PSReadLineKeyHandler -Key 'Alt+(' `
    -BriefDescription ParenthesizeSelection `
    -LongDescription "Put parentheses around the selection or entire line and move the cursor to after the closing parenthesis" `
    -ScriptBlock {
        param($key, $arg)

        $selectionStart = $null
        $selectionLength = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

        if ($selectionStart -ne -1) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $selectionStart,
                $selectionLength,
                '(' + $line.Substring($selectionStart, $selectionLength) + ')'
            )
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
            [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
        }
    }

# Each time you press Alt+', this key handler will change the token under or before the cursor.
# It will cycle through single quotes, double quotes, or no quotes each time it is invoked.
Set-PSReadLineKeyHandler -Key "Alt+'" `
    -BriefDescription ToggleQuoteArgument `
    -LongDescription "Toggle quotes on the argument under the cursor" `
    -ScriptBlock {
        param($key, $arg)

        $ast = $null
        $tokens = $null
        $errors = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

        $tokenToChange = $null
        foreach ($token in $tokens) {
            $extent = $token.Extent
            if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
                $tokenToChange = $token

                # If the cursor is at the end (it's really 1 past the end) of the previous token,
                # we only want to change the previous token if there is no token under the cursor.
                if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext()) {
                    $nextToken = $foreach.Current
                    if ($nextToken.Extent.StartOffset -eq $cursor) {
                        $tokenToChange = $nextToken
                    }
                }
                break
            }
        }

        if ($tokenToChange -ne $null) {
            $extent = $tokenToChange.Extent
            $tokenText = $extent.Text
            if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"') {
                # Switch to no quotes
                $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
            } elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'") {
                # Switch to double quotes
                $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
            } else {
                # Add single quotes
                $replacement = "'" + $tokenText + "'"
            }

            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $extent.StartOffset,
                $tokenText.Length,
                $replacement
            )
        }
    }

# Enable tab completion for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

# Enable tab completion for Winget
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}