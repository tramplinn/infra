#!/bin/sh
# judge0's own isolate_job.rb hardcodes --cg-timing/--no-cg-timing on every
# invocation (extract/compile/run). Isolate 2.0 dropped that flag — cgroup v2
# timing is unconditional now — so it exits with "unrecognized option" before
# the sandbox even runs, and judge0 reports "wrong_answer" against isolate's
# own --help text. Strip it here instead of patching judge0's app code.
for arg in "$@"; do
  shift
  case "$arg" in
    --cg-timing | --no-cg-timing) continue ;;
  esac
  set -- "$@" "$arg"
done
exec /usr/local/bin/isolate-real "$@"
