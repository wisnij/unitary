#!/usr/bin/env bash
#
# Renders the Google Play store graphics into
# fastlane/metadata/android/en-US/images/:
#
#   icon.png             512x512 32-bit PNG with alpha, from
#                        assets/icon/unitary.svg
#   featureGraphic.png   1024x500 24-bit PNG with no alpha, from
#                        assets/store/feature_graphic.svg
#
# The feature graphic's text uses the font bundled in assets/store/fonts/.
# Inkscape finds it through a temporary fontconfig file, so it does not need
# to be installed; the script fails rather than let Inkscape substitute a
# different font.  The graphic also embeds the icon's SVG and the worksheet
# screenshot from the phone set, so re-render after changing either.
#
# Requirements (development-only; the rendered images are committed):
#   - inkscape      (SVG rasterization)
#   - magick        (ImageMagick, for the final PNG formats)
#   - fc-match      (fontconfig, to confirm the bundled font is used)
#
# Usage:
#   tool/generate_store_graphics.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

ICON_SVG="assets/icon/unitary.svg"
FEATURE_SVG="assets/store/feature_graphic.svg"
FONT_DIR="${ROOT_DIR}/assets/store/fonts"
FONT_FAMILY="Anton"
FONT_FILE="${FONT_DIR}/Anton-Regular.ttf"
OUT_DIR="fastlane/metadata/android/en-US/images"
# The bottom colour of the feature graphic's background gradient, used when
# flattening away the alpha channel.
FEATURE_BACKGROUND="#0f0d2a"

for tool in inkscape magick fc-match; do
    if ! command -v "${tool}" >/dev/null 2>&1; then
        echo "error: ${tool} is required" >&2
        exit 1
    fi
done
for file in "${ICON_SVG}" "${FEATURE_SVG}"; do
    if [[ ! -f ${file} ]]; then
        echo "error: ${file} not found" >&2
        exit 1
    fi
done
if [[ ! -f ${FONT_FILE} ]]; then
    echo "error: font ${FONT_FAMILY} not found at ${FONT_FILE#"${ROOT_DIR}/"}" >&2
    exit 1
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

# A fontconfig configuration that adds the bundled font directory to the
# system configuration, with its own cache so nothing outside TMP_DIR is
# written.
cat > "${TMP_DIR}/fonts.conf" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <include ignore_missing="yes">/etc/fonts/fonts.conf</include>
  <dir>${FONT_DIR}</dir>
  <cachedir>${TMP_DIR}/fontcache</cachedir>
</fontconfig>
EOF
export FONTCONFIG_FILE="${TMP_DIR}/fonts.conf"

matched="$(fc-match -f '%{file}' "${FONT_FAMILY}")"
if [[ ${matched} != "${FONT_FILE}" ]]; then
    echo "error: font ${FONT_FAMILY} resolves to ${matched}, not the bundled" \
        "${FONT_FILE#"${ROOT_DIR}/"}" >&2
    exit 1
fi

mkdir -p "${OUT_DIR}"

echo "Rendering ${ICON_SVG} -> ${OUT_DIR}/icon.png (512x512, RGBA)"
inkscape "${ICON_SVG}" -w 512 -h 512 -o "${TMP_DIR}/icon.png"
magick "${TMP_DIR}/icon.png" -strip "PNG32:${OUT_DIR}/icon.png"

echo "Rendering ${FEATURE_SVG} -> ${OUT_DIR}/featureGraphic.png (1024x500, RGB)"
inkscape "${FEATURE_SVG}" -w 1024 -h 500 -o "${TMP_DIR}/feature.png"
magick "${TMP_DIR}/feature.png" -background "${FEATURE_BACKGROUND}" \
    -alpha remove -alpha off -strip "PNG24:${OUT_DIR}/featureGraphic.png"

echo "Done.  Review the rendered images and commit them."
