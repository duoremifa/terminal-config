# Workaround for git 2.33 bug on this machine:
# `git push` via Git\cmd\git.exe wrapper loses cwd when spawning push subprocess,
# reporting "fatal: not a git repository". Direct invocation of the real
# git-push.exe in mingw64/libexec/git-core works fine.
#
# Usage: gitp <args>   (drop-in replacement for `git push`)

$gitPushExe = "C:\Users\min.dai\AppData\Local\Programs\Git\mingw64\libexec\git-core\git-push.exe"

function gitp {
    if (-not (Test-Path $gitPushExe)) {
        Write-Warning "git-push.exe not found at $gitPushExe"
        return
    }
    & $gitPushExe @args
}
