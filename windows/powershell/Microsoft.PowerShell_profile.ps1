# PowerShell 5.1 profile - modular entry point
# Loads everything under profile.d\ in sorted order.
# Add new modules there (06-xxx.ps1, 07-xxx.ps1, ...) instead of editing this file.

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$pd = Join-Path $here "profile.d"

if (Test-Path $pd) {
    Get-ChildItem -LiteralPath $pd -Filter *.ps1 -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "00-entry.ps1" } |
        Sort-Object Name |
        ForEach-Object {
            try { . $_.FullName }
            catch { Write-Warning "profile load failed: $($_.Name): $_" }
        }
}
