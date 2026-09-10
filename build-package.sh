#!/usr/bin/env bash
set -euo pipefail

scheme="${1:?usage: ./build-package.sh rootless|roothide}"
case "$scheme" in
  rootless|roothide) ;;
  *) echo "Unsupported scheme: $scheme" >&2; exit 2 ;;
esac

cp "control.${scheme}" control
make clean THEOS_PACKAGE_SCHEME="$scheme"
make package THEOS_PACKAGE_SCHEME="$scheme" FINALPACKAGE=1 DEBUG=0
