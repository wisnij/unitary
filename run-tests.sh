#!/bin/bash
# Run all linting steps and tests, and report on test coverage
set -eu

(
    set -x
    pre-commit run -a
    flutter analyze
    flutter test --coverage
    dart run cobertura show
)

if [[ ${ENABLE_ANDROID_INTEGRATION_TESTS:-} == "true" ]]; then
    # Device id matches CI's Android-emulator step
    # (.github/actions/test/action.yml) — the default first-emulator adb port.
    : ${DEVICE_ID:="emulator-5554"}

    android_sdk="$(flutter doctor -v | grep -oP 'Android SDK at \K.*' | head -1)"
    if [[ -z $android_sdk ]]; then
        echo "No Android SDK found (flutter doctor); cannot run integration tests" >&2
        exit 1
    fi
    adb="$android_sdk/platform-tools/adb"
    emulator="$android_sdk/emulator/emulator"

    is_booted () {
        "$adb" -s "$DEVICE_ID" shell getprop sys.boot_completed 2>/dev/null |
            tr -d '\r' | grep -q '^1$'
    }

    started_emulator=0
    if "$adb" devices | grep -qE "^${DEVICE_ID}[[:space:]]+device" && is_booted; then
        echo "Android emulator already running at $DEVICE_ID"
    else
        avd_name="$("$emulator" -list-avds | head -1)"
        if [[ -z $avd_name ]]; then
            echo "No Android AVD available; cannot run integration tests" >&2
            exit 1
        fi
        echo "Starting Android emulator ($avd_name)..."
        (set -x; "$emulator" -avd "$avd_name" -no-window -no-audio -no-boot-anim &)
        started_emulator=1
        "$adb" wait-for-device
        until is_booted; do
            sleep 1
        done
    fi

    # Only tear down an emulator this script itself started — leave one the
    # developer already had running (e.g. from Android Studio) alone.
    cleanup_emulator () {
        if [[ $started_emulator -eq 1 ]]; then
            echo "Shutting down Android emulator..."
            (set -x; "$adb" -s "$DEVICE_ID" emu kill || true)
        fi
    }
    trap cleanup_emulator EXIT

    for f in integration_test/*.dart; do
        (set -x; flutter test "$f" -d "$DEVICE_ID")
    done
fi
