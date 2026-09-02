![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-black.svg)
![Flutter](https://img.shields.io/badge/Flutter-Dart%203-02569b.svg)
![SalesIQ Mobilisten](https://img.shields.io/badge/SalesIQ%20Mobilisten-Flutter-1a73e8.svg)

# Mobilisten sample app — Flutter

A unified showcase of the Zoho SalesIQ Mobilisten SDK for Flutter. The app walks through every major
capability of the SDK — live chat, calls, the visitor API, the launcher, knowledge base, help
center, notifications, and events — across eleven purpose-built screens that share one design system.

The SDK is initialized automatically at startup and push registration is automatic; the UI only
reports status and lets you exercise each API. Nothing here uses deprecated APIs.

## Features

Eleven screens, in a fixed order, each mapping to a slice of the SDK:

1. **Home** — dashboard for every module, with a hero that reflects the automatic SDK init status.
2. **Core & configuration** — global runtime configuration and live init status. No manual init
   button; startup is automatic.
3. **Launcher** — launcher visibility modes, drag-to-dismiss, operator image, and position.
4. **Visitor** — full visitor profile via `updateProfile`, plus registration/deregistration.
5. **Chat** — start conversations and toggle chat-window components.
6. **Calls** — audio/video call entry points and live call state via the calls plugin.
7. **Knowledge base** — browse and search self-service articles and categories.
8. **Homepage & help center** — homepage widget visibility and the AI/agent-backed help center.
9. **Notifications** — push status (registered automatically), in-app notification toggle, action
   source, and the last received payload.
10. **Events console** — a live feed of every SDK event across chat, calls, launcher, KB, and
    notifications.
11. **Settings** — set your App key / Access key, choose light / dark / system appearance, and view
    the SDK version.

## Prerequisites

- Flutter SDK with Dart 3 (`sdk: ">=3.0.0 <4.0.0"`; the sample uses records, switch expressions, and
  exhaustive enum patterns).
- **iOS**: Xcode and CocoaPods.
- **Android**: JDK 17 and the Android SDK (`compileSdk`/`targetSdk` 35).
- A Zoho SalesIQ account with App and Access keys for your iOS and Android bundle identifiers.

The example depends on the sibling plugins via path dependencies
(`salesiq_mobilisten` and `salesiq_mobilisten_calls` under `../packages/`), so it must be run from
within this repository.

## Install and run

```sh
cd example
flutter pub get
flutter run           # on a connected device or simulator/emulator
```

To target a specific platform:

```sh
flutter run -d android
flutter run -d ios
```

Calls features are best exercised on a physical device.

## Adding your App key and Access key

The app ships with placeholder credentials and starts in a graceful "keys required" state until you
provide real keys.

- **Recommended:** open the **Settings** screen in the running app, paste your App key and Access
  key, and save. The SDK re-initializes with the new credentials.
- The placeholders live in `lib/state/app_state.dart`
  (`INSERT_ANDROID_APP_KEY` / `INSERT_ANDROID_ACCESS_KEY` and the iOS pair), which is also the init
  call site.

Generate keys for your bundle ids from the SalesIQ portal.

## Screenshots

Placeholder references — drop images in `assets/screenshots/` to populate this section.

| Home | Visitor | Settings |
|---|---|---|
| ![Home](assets/screenshots/home-light.png) | ![Visitor](assets/screenshots/visitor.png) | ![Settings](assets/screenshots/settings.png) |

## Design system

All six Mobilisten sample apps (React Native, Android/Compose, Flutter, Cordova, iOS SwiftUI, iOS
UIKit) share a single design system — one token set for color, spacing, and type, and the same
component vocabulary and eleven-screen inventory. No screen hardcodes a color, size, or font value;
everything comes from `lib/theme/tokens.dart`.

## Light and dark mode

The app follows the OS appearance by default and provides a light / dark / system override in
**Settings**. Every color token is defined as a light/dark pair pre-checked for WCAG-AA contrast.
