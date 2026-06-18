#!/usr/bin/env bash
#
# Regenerate the application launcher/favicon icons from the source SVG.
#
# Source of truth: assets/icon/unitary.svg (embeds DejaVuSansMono-Bold.ttf).
# This script rasterizes the SVG to a 1024x1024 PNG master and then runs
# flutter_launcher_icons to produce the per-platform Android, iOS, and web
# assets.
#
# Requirements (development-only; not needed for a normal app build, since the
# generated assets are committed):
#   - inkscape        (SVG rasterization; honors the embedded font / filters)
#   - DejaVu Sans Mono Bold font available to fontconfig, or the bundled
#     assets/icon/DejaVuSansMono-Bold.ttf installed
#
# Usage:
#   tool/generate_icons.sh

set -euo pipefail

# Resolve repo root from this script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

SVG="assets/icon/unitary.svg"
PNG="assets/icon/unitary.png"

if [[ ! -f "${SVG}" ]]; then
    echo "error: ${SVG} not found" >&2
    exit 1
fi

if ! command -v inkscape >/dev/null 2>&1; then
    echo "error: inkscape is required to rasterize ${SVG}" >&2
    exit 1
fi

echo "Rasterizing ${SVG} -> ${PNG} (1024x1024)"
inkscape "${SVG}" -w 1024 -h 1024 -o "${PNG}"

echo "Generating platform icons with flutter_launcher_icons"
dart run flutter_launcher_icons

echo "Done.  Review the generated assets and commit them."
