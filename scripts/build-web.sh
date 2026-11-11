#!/usr/bin/env bash
# Release-build Bolajonim for the web into ./dist (index.html at the root).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FLUTTER_VERSION="3.47.9"
FLUTTER_SHA256="25ed8c3c29d51a7353f2a944310b478af8214920639524b19c50a19e6c044c5a"

export CI="${CI:-true}"
export FLUTTER_SUPPRESS_ANALYTICS=true

ensure_flutter() {
  if command -v flutter >/dev/null 2>&1; then
    return
  fi

  local dest="${FLUTTER_ROOT:-$HOME/.cache/flutter}"
  local parent
  parent="$(dirname "$dest")"

  if [[ ! -x "$dest/bin/flutter" ]]; then
    local tarball
    tarball="$(mktemp)"
    curl -fL --retry 3 --retry-delay 2 -o "$tarball" \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    echo "${FLUTTER_SHA256}  ${tarball}" | sha256sum -c -
    mkdir -p "$parent"
    rm -rf "$parent/flutter" "$dest"
    tar -xf "$tarball" -C "$parent"
    if [[ "$dest" != "$parent/flutter" ]]; then
      mv "$parent/flutter" "$dest"
    fi
    rm -f "$tarball"
  fi

  export PATH="$dest/bin:$PATH"
}

ensure_flutter

flutter config --no-analytics --no-cli-animations >/dev/null
flutter pub get

define_args=()
if [[ -n "${API_BASE_URL:-}" ]]; then
  define_args+=(--dart-define="API_BASE_URL=${API_BASE_URL}")
fi

rm -rf dist
flutter build web --release --no-wasm-dry-run --no-source-maps -o dist "${define_args[@]}"

test -f dist/index.html
echo "Web build written to dist/"
