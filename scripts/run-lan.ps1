<#
.SYNOPSIS
  Run Flutter web so phones on the same Wi-Fi can open it (e.g. iPhone Safari).

.EXAMPLE
  .\scripts\run-lan.ps1
  .\scripts\run-lan.ps1 -WebPort 8082
#>
param(
  [int]$WebPort = 8082,
  [int]$ApiPort = 8081
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

$wifiIp = (
  Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object {
    $_.IPAddress -like '192.168.*' -and $_.PrefixOrigin -ne 'WellKnown'
  } |
  Select-Object -First 1
).IPAddress

if (-not $wifiIp) {
  throw "No Wi-Fi IP found (expected 192.168.x.x). Connect to Wi-Fi first."
}

$apiUrl = "http://${wifiIp}:${ApiPort}"
$appUrl = "http://${wifiIp}:${WebPort}"

Write-Host ""
Write-Host "=== Bolajonim LAN test ===" -ForegroundColor Yellow
Write-Host "iPhone / phone URL: $appUrl" -ForegroundColor Green
Write-Host "API URL:            $apiUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "Requirements:" -ForegroundColor Yellow
Write-Host "  1) Backend running on port $ApiPort (restart after CORS change)"
Write-Host "  2) Phone on the SAME Wi-Fi as this PC"
Write-Host "  3) Windows Firewall allows inbound TCP $WebPort and $ApiPort"
Write-Host "  4) Open Safari and use: $appUrl" -ForegroundColor White
Write-Host ""

flutter run -d web-server `
  --web-hostname=0.0.0.0 `
  --web-port=$WebPort `
  "--dart-define=API_BASE_URL=$apiUrl"
