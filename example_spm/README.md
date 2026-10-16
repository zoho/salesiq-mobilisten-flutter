# my_flutter_app

A Flutter project pre-configured with:
- **Swift Package Manager (SPM)** support via `ios/Package.swift`
- **UISceneDelegate** lifecycle (no storyboard scene, programmatic window setup)
- **CocoaPods** for Flutter engine embedding (required alongside SPM)
- iOS 16+ deployment target

---

## Project structure

```
my_flutter_app/
├── lib/
│   └── main.dart                   # Flutter entry point
├── pubspec.yaml
└── ios/
    ├── Package.swift               # SPM manifest — add Swift packages here
    ├── Podfile                     # CocoaPods — Flutter engine + ObjC plugins
    ├── Runner.xcworkspace/         # Open this in Xcode
    ├── Runner.xcodeproj/
    └── Runner/
        ├── AppDelegate.swift       # UISceneSession lifecycle callbacks
        ├── SceneDelegate.swift     # UIWindowSceneDelegate + FlutterEngine boot
        ├── Runner-Bridging-Header.h
        └── Info.plist              # UIApplicationSceneManifest configured
```

---

## Getting started

### 1. Install Flutter & dependencies

```bash
flutter pub get
cd ios && pod install
```

### 2. Open in Xcode

Always open the **workspace**, not the project:

```bash
open ios/Runner.xcworkspace
```

### 3. Run

```bash
flutter run
```

---

## Adding Swift packages (SPM)

Edit `ios/Package.swift` and add your package to `dependencies` and the target's `dependencies` array:

```swift
dependencies: [
    .package(url: "https://github.com/some-org/some-lib.git", from: "2.0.0"),
],
targets: [
    .target(
        name: "MyFlutterApp",
        dependencies: ["SomeLib"],
        ...
    )
]
```

Then in Xcode → File → Packages → Resolve Package Versions.

> **Note:** Flutter plugins that ship a CocoaPods podspec but no SPM manifest must still be declared in `Podfile`. Pure-Swift packages with a `Package.swift` can go directly into `ios/Package.swift`.

---

## SceneDelegate details

`SceneDelegate.swift` boots a `FlutterEngine`, registers plugins, and sets the root view controller programmatically — no Main.storyboard scene is used. `Info.plist` declares the scene configuration pointing at `SceneDelegate`:

```xml
<key>UISceneDelegateClassName</key>
<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
```

`AppDelegate.swift` returns the correct `UISceneConfiguration` and handles session discard events.
