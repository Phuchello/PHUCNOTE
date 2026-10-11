# Optional desktop study: installed Microsoft PowerPoint only, no download.
$ErrorActionPreference = 'Stop'
$pocRepo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
$pocSource = Join-Path $pocRepo 'fixtures\document_lab\lecture_slides_network_security.pptx'
$pocTarget = Join-Path $pocRepo 'fixtures\document_lab\lecture_slides_network_security_converted.pdf'
$pocPowerPoint = $null
$pocPresentation = $null
try {
    $pocPowerPoint = New-Object -ComObject PowerPoint.Application
    $pocPresentation = $pocPowerPoint.Presentations.Open($pocSource, -1, 0, 0)
    # ppSaveAsPDF = 32. Source opens read-only and is never saved.
    $pocPresentation.SaveAs($pocTarget, 32)
    Write-Output "PowerPoint $($pocPowerPoint.Version): $pocTarget"
} finally {
    if ($null -ne $pocPresentation) { $pocPresentation.Close(); [void][Runtime.InteropServices.Marshal]::ReleaseComObject($pocPresentation) }
    if ($null -ne $pocPowerPoint) { $pocPowerPoint.Quit(); [void][Runtime.InteropServices.Marshal]::ReleaseComObject($pocPowerPoint) }
}
