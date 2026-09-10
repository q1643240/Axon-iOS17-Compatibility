#!/usr/bin/env bash
set -euo pipefail

scheme="${1:?usage: ./build-package.sh rootless|roothide}"
case "$scheme" in
  rootless|roothide) ;;
  *) echo "Unsupported scheme: $scheme" >&2; exit 2 ;;
esac

cp "control.${scheme}" control
make clean THEOS_PACKAGE_SCHEME="$scheme"
make stage THEOS_PACKAGE_SCHEME="$scheme" FINALPACKAGE=1 DEBUG=0

# Official Theos can inherit RootHide rpaths from a shared SDK checkout.
# Rootless binaries must not carry RootHide's .jbroot lookup paths.
if [ "$scheme" = "rootless" ]; then
  find .theos -type f -exec sh -c '
    file "$1" | grep -q "Mach-O" || exit 0
    install_name_tool -delete_rpath @loader_path/.jbroot/Library/Frameworks "$1" 2>/dev/null || true
    install_name_tool -delete_rpath @loader_path/.jbroot/usr/lib "$1" 2>/dev/null || true
    ldid -S "$1"
  ' sh {} \;
fi

make package THEOS_PACKAGE_SCHEME="$scheme" FINALPACKAGE=1 DEBUG=0
