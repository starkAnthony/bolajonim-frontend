<#
.SYNOPSIS
  Expose Bolajonim Flutter web + local backend to the internet via Cloudflare Tunnel.

.DESCRIPTION
  1) Checks backend on localhost:8081
  2) Opens a public tunnel to the API
  3) Runs Flutter web with that API URL baked in
  4) Opens a public tunnel to the web app
  5) Prints the link you can send to clients

  Keep this PowerShell window open. Your PC must stay on and online.

.PARAMETER ApiPort
  Local Spring Boot port (default 8081).

.PARAMETER WebPort
  Local Flutter web port (default 8080).

.EXAMPLE
  .\scripts\share-demo.ps1
#>
param(
  [int]$ApiPort = 8081,
  [int]$WebPort = 8080
)

$ErrorActionPreference = "Stop"

function Test-LocalPort {
  param([int]$Port)
  return (Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded
}

function Start-CloudflareTunnel {
  param(
    [int]$Port,
    [string]$Label
  )

  $logFile = Join-Path $env:TEMP "bolajonim-tunnel-$Label.log"
  if (Test-Path $logFile) { Remove-Item $logFile -Force }

  Write-Host "Starting Cloudflare tunnel for $Label (localhost:$Port)..." -ForegroundColor Cyan

  $proc = Start-Process -FilePath "cloudflared" `
    -ArgumentList @("tunnel", "--url", "http://localhost:$Port") `
    -RedirectStandardError $logFile `
    -PassThru `
    -WindowStyle Hidden

  $publicUrl = $null
  for ($i = 0; $i -lt 45; $i++) {
    Start-Sleep -Seconds 2
    if (-not (Test-Path $logFile)) { continue }

    $content = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
    if ($content -match '(https://[a-z0-9-]+\.trycloudflare\.com)') {
      $publicUrl = $Matches[1]
      break
    }
  }

  if (-not $publicUrl) {
    throw "Could not read public URL for $Label. Open log: $logFile"
  }

  Write-Host "  $Label -> $publicUrl" -ForegroundColor Green
  return @{
    Url     = $publicUrl
    Process = $proc
    LogFile = $logFile
  }
}

$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

Write-Host ""
Write-Host "=== Bolajonim demo link (Cloudflare Tunnel) ===" -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Command cloudflared -ErrorAction SilentlyContinue)) {
  throw "cloudflared not found. Install: winget install Cloudflare.cloudflared"
}

if (-not (Test-LocalPort $ApiPort)) {
  Write-Host "Backend is not reachable on http://localhost:$ApiPort" -ForegroundColor Red
  Write-Host "Start it first in another terminal:" -ForegroundColor Yellow
  Write-Host "  cd C:\Users\salok\IdeaProjects\flutter-backend\bolajonim-backend"
  Write-Host "  .\gradlew :taskhub-cmn-cmn:compileJava :taskhub-cmn-api:bootRun"
  throw "Backend not running."
}

$apiTunnel = Start-CloudflareTunnel -Port $ApiPort -Label "api"
$apiPublicUrl = $apiTunnel.Url

Write-Host ""
Write-Host "Starting Flutter web on port $WebPort (API -> $apiPublicUrl)..." -ForegroundColor Cyan

$flutterLog = Join-Path $env:TEMP "bolajonim-flutter-web.log"
if (Test-Path $flutterLog) { Remove-Item $flutterLog -Force }

$flutterProc = Start-Process -FilePath "flutter" `
  -ArgumentList @(
    "run", "-d", "web-server",
    "--web-hostname=0.0.0.0",
    "--web-port=$WebPort",
    "--dart-define=API_BASE_URL=$apiPublicUrl"
  ) `
  -WorkingDirectory $root `
  -RedirectStandardOutput $flutterLog `
  -RedirectStandardError $flutterLog `
  -PassThru `
  -WindowStyle Hidden

$webReady = $false
for ($i = 0; $i -lt 120; $i++) {
  Start-Sleep -Seconds 2
  if (Test-LocalPort $WebPort) {
    $webReady = $true
    break
  }
}

if (-not $webReady) {
  throw "Flutter web did not start on port $WebPort. Log: $flutterLog"
}

Write-Host "  Flutter web ready on http://localhost:$WebPort" -ForegroundColor Green

$appTunnel = Start-CloudflareTunnel -Port $WebPort -Label "app"
$appPublicUrl = $appTunnel.Url

$linksFile = Join-Path $root "share-demo-link.txt"
@(
  "Bolajonim demo links (generated $(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
  ""
  "SEND THIS TO CLIENTS (app):"
  $appPublicUrl
  ""
  "API tunnel (for your reference):"
  $apiPublicUrl
  ""
  "Notes:"
  "- Keep this PC on and this script running."
  "- Quick tunnel URL changes when you restart cloudflared."
  "- For a more stable URL, use a free Cloudflare account + named tunnel."
) | Set-Content -Encoding UTF8 $linksFile

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  SHARE THIS LINK WITH YOUR CLIENT:" -ForegroundColor White
Write-Host "  $appPublicUrl" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Saved to: $linksFile"
Write-Host "Press Ctrl+C to stop tunnels and Flutter."
Write-Host ""

try {
  while ($true) {
    Start-Sleep -Seconds 30
    if ($flutterProc.HasExited) {
      Write-Host "Flutter web stopped unexpectedly." -ForegroundColor Red
      break
    }
  }
} finally {
  Write-Host "Stopping tunnels and Flutter..." -ForegroundColor Yellow
  foreach ($p in @($flutterProc, $apiTunnel.Process, $appTunnel.Process)) {
    if ($p -and -not $p.HasExited) {
      Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
    }
  }
}
