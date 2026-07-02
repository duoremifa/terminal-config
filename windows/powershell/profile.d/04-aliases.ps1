# Aliases - the short names you'll type 100x a day

# Navigation
function ..  { Set-Location .. }
function ... { Set-Location ..\.. }

# Listing
function ll  { Get-ChildItem $args -Force | Format-Table Mode, LastWriteTime, Length, Name -AutoSize }
function la  { Get-ChildItem $args -Force -Hidden }

# Search
function grep($pattern, $path = ".") {
    Get-ChildItem -LiteralPath $path -Recurse -File -ErrorAction SilentlyContinue |
        Select-String -LiteralPattern $pattern
}
# Also expose as 'sg' (search grep) so you have both English + familiar names
New-Alias -Name sg -Value grep -Force -ErrorAction SilentlyContinue

# Open-with-default-app
function ii  { Invoke-Item $args[0] }

# Edit profile
function ep  { code "$env:USERPROFILE\Documents\WindowsPowerShell" }

# Reload profile without restarting terminal
function reload {
    . $PROFILE
    "profile reloaded."
}
