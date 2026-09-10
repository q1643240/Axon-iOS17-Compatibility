# Axon iOS 16–17 Compatibility

A GPL-3.0 maintenance fork of Axon for jailbroken **iOS 16 and iOS 17** devices. It keeps Axon's app-grouped Lock Screen and Notification Center notification selector while modernising packaging, binary architecture, preference handling, and build automation.

> **Status:** source and package layout are statically audited. iOS 16/17 runtime behavior must still be verified separately on real devices; private SpringBoard interfaces can change between iOS releases.

## Attribution and license

This repository is based on Axon by **Nepeta** and **Baw Appie**, and the iOS 16 compatibility work by **dakotadawolfe**. The original GPL-3.0 license is retained in [`LICENSE`](LICENSE). Derivative distribution must remain GPL-3.0 compliant.

## Compatibility

| Package | Intended environment | Payload root | Package architecture |
|---|---|---:|---|
| `com.q1643240.axon17.rootless` | Dopamine / palera1n Rootless and compatible iOS 16–17 rootless setups | `/var/jb` | `iphoneos-arm64` |
| `com.q1643240.axon17.roothide` | RootHide on iOS 16–17 | `/Library` (relocated by RootHide) | `iphoneos-arm64e` |

Both packages compile their tweak and preference bundle as **arm64e**. They are deliberately mutually exclusive and also conflict with the legacy `me.nepeta.axon` package. They use distinct package IDs and preference domain `com.q1643240.axon17`.

## Changes in 1.5.1

- Adds maintained iOS 16–17 build targeting with arm64e injection binaries.
- Supplies separate Rootless and RootHide package manifests and build paths.
- Uses `<rootless.h>`/`ROOT_PATH` for Rootless preference assets and `<roothide.h>`/`jbroot()` only for RootHide.
- Repairs the notification wrapper initialization/ownership path.
- Keeps UI collection reloads on the main thread and corrects date-sort comparison.
- Removes repeated `tableHeaderView` replacement during setting-cell creation; header layout is now adjusted only during layout, avoiding a common Preferences lifecycle instability.
- Replaces the former Axon preference namespace with `com.q1643240.axon17`, so legacy settings cannot silently affect this fork.

## Build

A public GitHub Actions workflow produces each package on a macOS runner from public dependencies only. It is intentionally enabled **only for this public GPL project**.

Local builds require the appropriate Theos installation:

```bash
# Standard Rootless
./build-package.sh rootless

# RootHide
./build-package.sh roothide
```

Always run `make clean` when changing schemes; the included script does this automatically. Packages are produced under `packages/`.

## Installation and testing

Install **only the matching package** for the installed jailbreak environment, then userspace-reboot/respring. Do not install both variants.

For each target environment, verify independently:

1. Settings opens without a blank page; navigate into and back from every Axon subpage.
2. Lock Screen and Notification Center create, update, clear, and select grouped notifications.
3. Horizontal and vertical modes, orientation/safe-area behavior, badges, and sorting.
4. Rootless iOS 16, Rootless iOS 17, RootHide iOS 16, and RootHide iOS 17.

A successful build/static audit is not a substitute for real-device verification.
