param([Parameter(Mandatory=$true)][string]$Adb, [string]$Device='emulator-5554')
$ErrorActionPreference='Stop'
$pocRepo=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$pocScratch=Join-Path $pocRepo 'scratch\pdf-functional-poc'
$pocArtifacts=Join-Path $pocRepo 'artifacts\pdf-functional-poc'
$pocPackage='com.phucnote.pdf_functional_poc'
$pocComponent="$pocPackage/.MainActivity"
$pocApk=Join-Path $pocRepo 'examples\pdf_functional_poc\build\app\outputs\flutter-apk\app-debug.apk'
& $Adb -s $Device install -r $pocApk | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'POC APK installation failed' }
$pocLaunch=& $Adb -s $Device shell am start -W -n $pocComponent
Start-Sleep -Seconds 3
$pocPidBefore=((& $Adb -s $Device shell pidof $pocPackage) -join '').Trim()
& $Adb -s $Device shell screencap -p /sdcard/pdf-poc-before-resume.png
& $Adb -s $Device pull /sdcard/pdf-poc-before-resume.png (Join-Path $pocScratch 'before-resume.png') | Out-Null
& $Adb -s $Device shell input keyevent KEYCODE_HOME
Start-Sleep -Seconds 1
$pocResume=& $Adb -s $Device shell am start -W -n $pocComponent
Start-Sleep -Seconds 2
$pocPidAfter=((& $Adb -s $Device shell pidof $pocPackage) -join '').Trim()
if (!$pocPidBefore -or $pocPidBefore -ne $pocPidAfter) { throw 'App process changed during background/resume' }
& $Adb -s $Device shell screencap -p /sdcard/pdf-poc-after-resume.png
& $Adb -s $Device pull /sdcard/pdf-poc-after-resume.png (Join-Path $pocScratch 'after-resume.png') | Out-Null
$pocLog=& $Adb -s $Device logcat -d --pid=$pocPidAfter
$pocLog | Set-Content -LiteralPath (Join-Path $pocScratch 'correct-package-log.txt') -Encoding utf8
$pocCrashes=@($pocLog | Select-String 'FATAL EXCEPTION|Fatal signal|ANR in com.phucnote.pdf_functional_poc')
if ($pocCrashes.Count) { throw 'POC crash/ANR evidence found' }
$pocForeground=@(& $Adb -s $Device shell dumpsys activity activities | Select-String "topResumedActivity.*$pocPackage|mResumedActivity.*$pocPackage")
if (!$pocForeground.Count) { throw 'POC did not resume to foreground' }
$pocMemory=& $Adb -s $Device shell dumpsys meminfo $pocPackage
$pocMemory | Set-Content -LiteralPath (Join-Path $pocScratch 'normal-app-meminfo.txt') -Encoding utf8
$pocMemoryTotals=[regex]::Match(($pocMemory -join "`n"),'TOTAL PSS:\s+(\d+)\s+TOTAL RSS:\s+(\d+)')
$pocProduction=@(& $Adb -s $Device shell pm list packages | Select-String '^package:com.phucnote.phucnote$')
$pocTrace=@{
    package=$pocPackage; pidBefore=$pocPidBefore; pidAfter=$pocPidAfter;
    background='ADB KEYCODE_HOME'; resume=$pocResume; launch=$pocLaunch;
    foreground=($pocForeground | ForEach-Object {$_.Line}); crashOrANRMatches=$pocCrashes.Count;
    productionPackageInstalled=($pocProduction.Count -gt 0);
    totalPSSKiB=if($pocMemoryTotals.Success){[int]$pocMemoryTotals.Groups[1].Value}else{$null};
    totalRSSKiB=if($pocMemoryTotals.Success){[int]$pocMemoryTotals.Groups[2].Value}else{$null};
    memorySampleOnly=$true;
    result='PASS process survives real background/resume; screenshots require visual inspection'
}
$pocTrace | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $pocArtifacts 'lifecycle-trace.json') -Encoding utf8
$pocTrace | ConvertTo-Json -Depth 5
