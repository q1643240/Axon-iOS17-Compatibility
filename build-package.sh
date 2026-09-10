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

# The Rootless build must never retain RootHide's .jbroot rpaths. Theos may
# restage binaries during `make package`, so normalize the finished DEB.
if [ "$scheme" = "rootless" ]; then
  deb=$(find packages -maxdepth 1 -type f -name '*.deb' | head -n 1)
  stage=$(mktemp -d)
  dpkg-deb -R "$deb" "$stage"
  find "$stage" -type f -exec sh -c '
    file "$1" | grep -q "Mach-O" || exit 0
    install_name_tool -delete_rpath @loader_path/.jbroot/Library/Frameworks "$1" 2>/dev/null || true
    install_name_tool -delete_rpath @loader_path/.jbroot/usr/lib "$1" 2>/dev/null || true
    ldid -S "$1"
  ' sh {} \;
  ! find "$stage" -type f -exec sh -c 'file "$1" | grep -q "Mach-O" && strings "$1" | grep -q "\.jbroot"' sh {} \;
  dpkg-deb -b "$stage" "$deb"
  rm -rf "$stage"
fi
