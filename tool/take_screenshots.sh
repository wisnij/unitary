#!/bin/bash
# Regenerates the README screenshots in doc/screenshots/.
#
# Boots the Android emulator (if no target device is already connected), runs
# integration_test/screenshots/take_screenshots.dart via flutter drive,
# and downscales the captured PNGs to the sizes the README embeds them at
# (480 px wide, except the two settings captures at 400 px so the pair fits
# side by side).
#
# The emulator is shut down afterwards only if this script started it.
#
# Requires ImageMagick ('magick') for the rescaling step.
set -eu

: "${DEVICE_ID:=emulator-5554}"
: "${AVD_NAME:=Pixel_6_Pro_API_33_13.0_}"

cd "$(dirname "$0")/.."

if ! command -v magick >/dev/null; then
  echo "error: ImageMagick ('magick') is required to rescale the screenshots" >&2
  exit 1
fi

device_ready () {
  adb devices | grep -qE "^${DEVICE_ID}[[:space:]]+device"
}

started_emulator=0
cleanup () {
  if [[ $started_emulator -eq 1 ]]; then
    adb -s "$DEVICE_ID" emu kill || true
  fi
}
trap cleanup EXIT

if ! device_ready; then
  echo "Starting emulator $AVD_NAME..."
  flutter emulators --launch "$AVD_NAME"
  started_emulator=1
  adb -s "$DEVICE_ID" wait-for-device
  until [[ "$(adb -s "$DEVICE_ID" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 2
  done
fi

flutter drive --profile \
  --driver=test_driver/screenshots_driver.dart \
  --target=integration_test/screenshots/take_screenshots.dart \
  -d "$DEVICE_ID"

cd doc/screenshots
for f in *.png; do
    (set -x; magick "$f" -resize 480x "$f")
done

echo "Done:"
identify *.png
