# profile.d/ entry point - dot-source every .ps1 in this folder, sorted by name
$d = Split-Path -Parent $MyInvocation.MyCommand.Path
if (Test-Path $d) {
    Get-ChildItem -LiteralPath $d -Filter *.ps1 -ErrorAction SilentlyContinue |
        Sort-Object Name |
        ForEach-Object {
            try { . $_.FullName }
            catch { Write-Warning "profile load failed: $($_.Name): $_" }
        }
}
