#!/bin/bash
# Runs integration_test/*.dart against the given device, bounded by a
# per-attempt timeout. If an attempt times out (as opposed to a genuine test
# failure), it's retried up to MAX_ATTEMPTS times — a flaky emulator hang
# shouldn't need a human to notice and re-run the job, but a real failure
# should surface immediately rather than be retried away.
set -u
# Job control: a backgrounded job gets its own process group (pgid == the
# job's leader pid), which sweep_process_group below relies on to reach
# flutter test's dart/gradle/adb descendants — a plain `timeout` only
# signals its immediate child, not further descendants.
set -m

: "${DEVICE_ID:=emulator-5554}"
readonly TIMEOUT_MINUTES=30
readonly MAX_ATTEMPTS=2

run_tests () {
  for f in integration_test/*.dart; do
    flutter test "$f" -d "$DEVICE_ID" || return 1
  done
}
export -f run_tests
export DEVICE_ID

# Terminates every process in the given job's process group. Safe to call
# even when nothing survives (kill's failure is silenced).
sweep_process_group () {
  local pgid=$1
  kill -TERM -- "-$pgid" 2>/dev/null || true
  sleep 2
  kill -KILL -- "-$pgid" 2>/dev/null || true
}

attempt=1
while true; do
  timeout --kill-after=30s "${TIMEOUT_MINUTES}m" bash -c run_tests &
  pid=$!
  wait "$pid"
  status=$?
  sweep_process_group "$pid"

  if [[ $status -eq 0 ]]; then
    exit 0
  fi

  if [[ $status -ne 124 ]]; then
    echo "Integration tests failed (exit $status); not retrying." >&2
    exit "$status"
  fi

  echo "Integration tests timed out after ${TIMEOUT_MINUTES}m (attempt $attempt/$MAX_ATTEMPTS)." >&2
  if [[ $attempt -ge $MAX_ATTEMPTS ]]; then
    echo "Giving up after $MAX_ATTEMPTS attempts." >&2
    exit 124
  fi

  attempt=$((attempt + 1))
done
