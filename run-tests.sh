#!/bin/bash
# Run all linting steps and tests, and report on test coverage
set -eux

pre-commit run -a
flutter analyze
flutter test --coverage
dart run cobertura show
