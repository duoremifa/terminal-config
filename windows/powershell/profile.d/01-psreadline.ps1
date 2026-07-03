# PSReadLine 2.3.6 - predictive intellisense + history polish
# Requires PSReadLine >= 2.2.6 (we have 2.3.6 in user Modules path)

# Only tune PSReadLine when running in a real interactive terminal
# (not under a harness / redirected output / background job)
if ([Environment]::UserInteractive -and -not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle InlineView
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
    Set-PSReadLineOption -MaximumHistoryCount 4000

    Set-PSReadLineKeyHandler -Key Tab -Function Complete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Terminal window title: "PS <current-dir> " so multiple windows are distinguishable
function global:prompt {
    $loc = Get-Location
    $short = ($loc.Path -replace [regex]::Escape($env:USERPROFILE), '~')
    $host.UI.RawUI.WindowTitle = "PS $short"
    "PS $short> "
}
