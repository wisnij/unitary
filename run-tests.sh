#!/bin/bash
# Run all linting steps and tests, and report on test coverage
set -eux

pre-commit run -a
flutter analyze
flutter test --coverage
dart run cobertura show

if [[ ${ENABLE_ANDROID_INTEGRATION_TESTS:-} = "true" ]]; then
    # Matches the device id CI's Android-emulator step runs against
    # (.github/actions/test/action.yml) — requires an Android emulator
    # already running locally at the default first-emulator adb port.
    for f in integration_test/*.dart; do
        flutter test "$f" -d emulator-5554
    done
fi
