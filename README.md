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

## Changes in 1.5.9

- Rebuilds top attachment as an idempotent, delayed StackView operation. It retries only at native view lifecycle/content-update points (no polling/timer), and marks initialization complete only after a real Dashboard StackView exists and the selector has been attached.
- Fixes the resulting configuration ordering so the newly attached top selector receives all current preferences before display.

## Changes in 1.5.8

- Performs an exact rollback of the horizontal top path to the initial device-verified sequence: synchronous configuration, KVC StackView retrieval, original constraints, arranged-subview insertion, and native content-update reordering.
- Keeps only the independently verified removal of the iOS 17 `resetIdleTimer` crash from the icon-tap path; later top-container fallback code does not participate in top layout.

## Changes in 1.5.7

- Restores the lock-screen top-selector attachment to the device-verified `SBDashBoardNotificationAdjunctListViewController` StackView/KVC path used by the initial working build.
- Removes the later notification-container top fallback that regressed the displayed top selector on the reported iOS 17 / Relaxin device.
- Retains the verified iOS 17 icon-tap crash removal and the remaining guarded notification-management paths.

## Changes in 1.5.6

- Fixes the iOS 17 top-position fallback being compressed to zero width by Auto Layout. The selector now has explicit leading/trailing constraints within the real notification container and is kept in front of notification-card subviews.
- Pins the top selector within the notification container, which places it below Lock Screen time/widgets and before the first notification card.

## Changes in 1.5.5

- Rebuilds the horizontal top-position attachment for iOS 17: both top and bottom now use the actual notification list container; top is pinned to its safe-area top rather than relying on the legacy dashboard adjunct `_stackView`.
- Prevents a legacy adjunct created early by Relaxin/iOS 17 from consuming Axon's single initialization state before the real notification container is available.
- Adds safe optional-interface checks for notification-history/reveal-hint operations, removes the obsolete idle-timer declaration, and routes configuration refreshes through the main queue.

## Changes in 1.5.4

- Rebuilds Axon's startup synchronization: when the notification list controller becomes visible, existing retained iOS 16/17 notifications are collected into Axon's local app index before the selector is refreshed. This fixes the empty selector after installing Axon while notifications already exist.
- Retains the latest notification reference through the refresh cycle and retries initial hydration until the system list has supplied requests.

## Changes in 1.5.3

- Adds RootHide/Relaxin-oriented iOS 17 packaging validation and keeps only RootHide relocation paths in the RootHide variant.
- Synchronizes Axon's local notification cache, icon list, count cache, and displayed selector after clearing one app or all app notifications.
- Replaces the legacy action sheet after a long press with an original frosted-glass, rounded-capsule notification action menu.
- Rebuilds the location subpage with scoped state, correct defaults, immediate Darwin preference reload, and stable specifier insertion/removal.
- Completes Simplified Chinese UI strings for settings, location controls, debug controls, and long-press actions.

## Changes in 1.5.2

- Fixes the verified iOS 17.3.1 SpringBoard crash when tapping an Axon notification icon: `SBIdleTimerGlobalCoordinator` no longer implements `resetIdleTimer`, so the obsolete unchecked call was removed.
- Adds capability guards around notification-controller, dispatcher, scroll-to-top, dashboard, and lock-screen stack private interfaces to avoid sending selectors that are unavailable on a particular iOS 16/17 build.
- Fixes the lock-screen stack attachment order when the expected stack is not available yet.
- Adds Simplified Chinese localization for the main settings page and Chinese labels/messages for the location, debug, and icon long-press menus.
- Adds maintained iOS 16–17 build targeting with arm64e injection binaries.

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
