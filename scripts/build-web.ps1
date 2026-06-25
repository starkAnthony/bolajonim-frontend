param(
  [Parameter(Mandatory = $true)]
  [string]$ApiBaseUrl
)

$ErrorActionPreference = "Stop"

Push-Location (Split-Path $PSScriptRoot -Parent)
try {
  flutter pub get
  flutter build web --release --dart-define=API_BASE_URL=$ApiBaseUrl
  Write-Host ""
  Write-Host "Build complete: build/web"
  Write-Host "Deploy with:  cd build/web; vercel --prod"
} finally {
  Pop-Location
}
