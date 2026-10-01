#!/bin/bash
# Captures screenshots of the app for the README or the Google Play listing.
#
# Usage: tool/take_screenshots.sh [readme|phone|seven-inch|ten-inch|store]
#
# readme (the default)
#   Regenerates the README screenshots in doc/screenshots/.  Boots the
#   Android emulator if no target device is already connected, runs
#   integration_test/screenshots/take_screenshots.dart via flutter drive, and
#   downscales the captured PNGs to the sizes the README embeds them at (480 px
#   wide, except the two settings captures at 400 px so the pair fits side by
#   side).  DEVICE_ID and AVD_NAME override the device.
#
# phone, seven-inch, ten-inch
#   Captures one store screenshot set into
#   fastlane/metadata/android/en-US/images/<set>/, replacing what is there.
#   Each target has its own emulator profile with an exact 9:16 or 16:9 screen,
#   created on first use from the API 35 google_apis x86_64 system image and
#   run on its own port, so it never captures on some other device.  The
#   captures use the dark theme, keep their full resolution, and have their
#   alpha channel removed, as Play requires.  They show only the app: the
#   capture records the Flutter surface, not the system status bar.
#
# store
#   All three store targets in turn.
#
# An emulator is shut down afterwards only if this script started it.
#
# Requires ImageMagick ('magick') for post-processing.
set -eu

cd "$(dirname "$0")/.."

target="${1:-readme}"

if ! command -v magick >/dev/null; then
  echo "error: ImageMagick ('magick') is required to process the screenshots" >&2
  exit 1
fi

started_emulators=()
cleanup () {
  local device
  for device in "${started_emulators[@]}"; do
    if [[ -n $device ]]; then
      adb -s "$device" emu kill || true
    fi
  done
}
trap cleanup EXIT

device_ready () {
  adb devices | grep -qE "^$1[[:space:]]+device"
}

wait_for_boot () {
  adb -s "$1" wait-for-device
  until [[ "$(adb -s "$1" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
    sleep 2
  done
}

capture_readme () {
  local device="${DEVICE_ID:-emulator-5554}"
  local avd="${AVD_NAME:-Pixel_6_Pro_API_33_13.0_}"

  if ! device_ready "$device"; then
    echo "Starting emulator $avd..."
    flutter emulators --launch "$avd"
    started_emulators+=("$device")
    wait_for_boot "$device"
  fi

  flutter drive --profile \
    --driver=test_driver/screenshots_driver.dart \
    --target=integration_test/screenshots/take_screenshots.dart \
    -d "$device"

  (
    cd doc/screenshots
    for f in *.png; do
      (set -x; magick "$f" -resize 480x "$f")
    done
    echo "Done:"
    identify ./*.png
  )
}

# The SDK root, found from adb's location (<sdk>/platform-tools/adb).
sdk_root () {
  dirname "$(dirname "$(readlink -f "$(command -v adb)")")"
}

# Sets the emulator profile for a store target: AVD name, base device
# profile, screen width and height in pixels, density, initial orientation,
# and the port the emulator runs on.  Each screen is exactly 9:16 or 16:9 and
# puts the app in a different layout: compact (phone), medium (7-inch: drawer
# and two panes), and expanded (10-inch: navigation rail and two panes).
store_profile () {
  case "$1" in
    phone)
      avd=Unitary_Store_Phone device_profile=pixel_2
      width=1080 height=1920 density=420 orientation=portrait port=5580
      ;;
    seven-inch)
      avd=Unitary_Store_Tablet7 device_profile="Nexus 7 2013"
      width=1080 height=1920 density=240 orientation=portrait port=5582
      ;;
    ten-inch)
      avd=Unitary_Store_Tablet10 device_profile=pixel_tablet
      width=2560 height=1440 density=320 orientation=landscape port=5584
      ;;
  esac
}

# Sets KEY=VALUE in an AVD config.ini, replacing any existing line for KEY.
set_avd_config () {
  local config="$1" key="$2" value="$3"
  sed -i "/^${key//./\\.}[[:space:]]*=/d" "$config"
  echo "$key=$value" >> "$config"
}

create_store_avd () {
  local avd="$1" device="$2" width="$3" height="$4" density="$5" orientation="$6"
  local config="$ANDROID_AVD_HOME/$avd.avd/config.ini"
  local image="system-images;android-35;google_apis;x86_64"

  if [[ -f $config ]]; then
    return
  fi
  echo "Creating emulator profile $avd..."
  echo no | "$(sdk_root)/cmdline-tools/latest/bin/avdmanager" create avd \
    --name "$avd" --package "$image" --device "$device"
  set_avd_config "$config" hw.lcd.width "$width"
  set_avd_config "$config" hw.lcd.height "$height"
  set_avd_config "$config" hw.lcd.density "$density"
  set_avd_config "$config" hw.initialOrientation "$orientation"
  # A device skin would impose the base profile's screen size.
  set_avd_config "$config" skin.name "${width}x${height}"
  set_avd_config "$config" skin.path "_no_skin"
  set_avd_config "$config" showDeviceFrame no
}

capture_store () {
  local target="$1"
  local avd device_profile width height density orientation port
  store_profile "$target"
  local device="emulator-$port"
  local set folder names
  case "$target" in
    phone)
      set=phone
      folder=phoneScreenshots
      names=(freeform worksheet currency browser unit-detail settings)
      ;;
    seven-inch)
      set=tablet
      folder=sevenInchScreenshots
      names=(freeform worksheet currency browser settings)
      ;;
    ten-inch)
      set=tablet
      folder=tenInchScreenshots
      names=(freeform worksheet currency browser settings)
      ;;
  esac
  local staging="build/screenshots/$target"
  local dest="fastlane/metadata/android/en-US/images/$folder"

  # avdmanager and the emulator default to different AVD directories on some
  # machines; pin both to the same one.
  export ANDROID_AVD_HOME="${ANDROID_AVD_HOME:-$HOME/.android/avd}"
  create_store_avd "$avd" "$device_profile" "$width" "$height" "$density" "$orientation"

  local started=0
  if ! device_ready "$device"; then
    echo "Starting emulator $avd on port $port..."
    "$(sdk_root)/emulator/emulator" -avd "$avd" -port "$port" \
      -no-window -no-audio -no-boot-anim -no-snapshot >/dev/null 2>&1 &
    started_emulators+=("$device")
    started=1
    wait_for_boot "$device"
  fi

  echo "Screen: $(adb -s "$device" shell wm size | tr -d '\r')," \
    "$(adb -s "$device" shell wm density | tr -d '\r')"

  adb -s "$device" shell cmd uimode night yes >/dev/null

  rm -rf "$staging"
  SCREENSHOT_DIR="$staging" flutter drive --profile \
    --driver=test_driver/screenshots_driver.dart \
    --target=integration_test/screenshots/take_screenshots.dart \
    --dart-define=SCREENSHOT_SET="$set" \
    -d "$device"

  mkdir -p "$dest"
  rm -f "$dest"/*.png
  local i=0 name
  for name in "${names[@]}"; do
    i=$((i + 1))
    local out
    out="$dest/$(printf '%02d' "$i")_$name.png"
    (set -x; magick "$staging/$name.png" -background black -alpha remove \
      -alpha off -strip "PNG24:$out")
  done
  echo "Done ($target):"
  identify "$dest"/*.png

  # Shut down now rather than at exit, so the store target does not end up
  # running three emulators at once.
  if [[ $started -eq 1 ]]; then
    adb -s "$device" emu kill || true
    while device_ready "$device"; do
      sleep 1
    done
    started_emulators=("${started_emulators[@]/$device}")
  fi
}

case "$target" in
  readme)
    capture_readme
    ;;
  phone|seven-inch|ten-inch)
    capture_store "$target"
    ;;
  store)
    for t in phone seven-inch ten-inch; do
      capture_store "$t"
    done
    ;;
  *)
    echo "usage: $0 [readme|phone|seven-inch|ten-inch|store]" >&2
    exit 2
    ;;
esac
