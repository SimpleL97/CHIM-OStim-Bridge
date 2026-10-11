# CHIM OStim Bridge - renders art/banner.html (written by make_banner.py) to art/banner.png
# (1920x1080) with Microsoft Edge in headless mode. Any Chromium browser works the same way.
#
#   python3 -I art\make_banner.py
#   .\art\render_banner.ps1

$ErrorActionPreference = 'Stop'
$art = $PSScriptRoot
$edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
          "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $edge) { throw "Microsoft Edge not found" }
$html = (Join-Path $art 'banner.html') -replace '\\', '/'
$png = Join-Path $art 'banner.png'
Remove-Item $png -ErrorAction SilentlyContinue
Start-Process -FilePath $edge -Wait -WindowStyle Hidden -ArgumentList @(
    '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
    '--window-size=1920,1080', "--screenshot=`"$png`"", "`"file:///$html`"")
if (-not (Test-Path $png)) { throw "banner.png was not written" }
Write-Host "written $png"
