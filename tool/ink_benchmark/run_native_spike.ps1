param([string]$Device = 'emulator-5554', [switch]$SkipBuild, [switch]$SmokeOnly)
$ErrorActionPreference = 'Stop'
$workspace = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$adb = Join-Path $workspace 'scratch/toolchain/android-sdk/platform-tools/adb.exe'
$out = Join-Path $workspace 'artifacts/ink-engine'
New-Item -ItemType Directory -Force $out | Out-Null
if (-not $SkipBuild) {
    & (Join-Path $workspace 'android/gradlew.bat') -p (Join-Path $workspace 'examples/ink_engine_native_spike') :app:assembleDebug --console=plain
    if ($LASTEXITCODE -ne 0) { throw 'Native build failed' }
}
& $adb -s $Device install -r (Join-Path $workspace 'examples/ink_engine_native_spike/app/build/outputs/apk/debug/app-debug.apk')
if ($LASTEXITCODE -ne 0) { throw 'Native install failed' }
$runId = [guid]::NewGuid().ToString()
& $adb -s $Device shell am force-stop com.phucnote.ink_spike
& $adb -s $Device shell am start -n com.phucnote.ink_spike/.MainActivity --es RUN_ID $runId --ez SMOKE_ONLY "$($SmokeOnly.IsPresent.ToString().ToLowerInvariant())"
$deadline = [DateTime]::UtcNow.AddMinutes(5)
$report = $null
while ([DateTime]::UtcNow -lt $deadline) {
    $raw = & $adb -s $Device shell run-as com.phucnote.ink_spike cat files/native_results.json 2>$null
    if ($LASTEXITCODE -eq 0) {
        $candidate = ($raw -join "`n") | ConvertFrom-Json
        if ($candidate.runId -eq $runId -and $candidate.status) { $report = $candidate; break }
    }
    Start-Sleep -Seconds 2
}
if (-not $report) { throw 'Native spike timed out; no fresh result' }
$raw | Set-Content -LiteralPath (Join-Path $out 'native_results.json') -Encoding utf8
if ($report.status -ne 'PASS') { throw "Native spike failed: $($report.error)" }
& $adb -s $Device shell input keyevent KEYCODE_HOME
Start-Sleep -Seconds 1
& $adb -s $Device shell am start -n com.phucnote.ink_spike/.MainActivity
Start-Sleep -Seconds 1
$raw = & $adb -s $Device shell run-as com.phucnote.ink_spike cat files/native_results.json
$resumed = ($raw -join "`n") | ConvertFrom-Json
if ($resumed.runId -ne $runId -or $resumed.completedCount -ne 1 -or $resumed.resumes -lt 2 -or $resumed.pauses -lt 1) {
    throw 'Lifecycle handoff check failed'
}
$raw | Set-Content -LiteralPath (Join-Path $out 'native_results.json') -Encoding utf8
& $adb -s $Device shell screencap -p /sdcard/phucnote-native-ink.png
& $adb -s $Device pull /sdcard/phucnote-native-ink.png (Join-Path $out 'native-spike.png')
& $adb -s $Device shell dumpsys meminfo com.phucnote.ink_spike | Set-Content -LiteralPath (Join-Path $out 'native-memory.txt')
& $adb -s $Device logcat -d -v brief -s InkSpike | Set-Content -LiteralPath (Join-Path $out 'native-smoke.log')
Write-Output "PASS smoke runId=$runId; historical samples, cancellation and pause/resume; exactInputFidelity=$($resumed.exactInputFidelity)"
