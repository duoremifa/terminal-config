# Integrations: Terminal-Icons (colored file icons) + zoxide (smart cd)

# Terminal-Icons - replaces default ls with color + NerdFont glyphs
# If your terminal lacks NerdFont glyphs, you'll see empty boxes - run: Disable-TerminalIconsFormatting
try {
    Import-Module Terminal-Icons -ErrorAction Stop
} catch {
    Write-Warning "Terminal-Icons not loaded: $_"
}

# zoxide - remembers your most-visited directories
# Usage: z <partial>   (jump), zi <partial> (interactive), a/z <args> (add)
# After this init, 'cd' is also zoxide-aware
$zo = Join-Path $env:USERPROFILE "zoxide\zoxide.exe"
if (Test-Path $zo) {
    # Add to PATH for this session
    if ($env:PATH -notlike "*\zoxide*") {
        $env:PATH = (Split-Path $zo) + ";" + $env:PATH
    }
    try {
        Invoke-Expression (& $zo init powershell | Out-String)
    } catch {
        Write-Warning "zoxide init failed: $_"
    }
}
