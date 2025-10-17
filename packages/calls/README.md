[![SupportedLanguages](https://img.shields.io/badge/Platforms-iOS%20%7C%20%20Android-green.svg)](https://flutter.dev/) [![Version](https://img.shields.io/badge/version-0.0.2-blue.svg)](https://mobilisten.io/)

# Zoho SalesIQ Mobilisten Calls Flutter Plugin

## Installation:

Please follow the steps mentioned below to install the Mobilisten Calls plugin in your Flutter
mobile application.

### Requirements

**Android**:
Ensure that your project meets the following requirements:

- Minimum Android Version: Android 6.0 (Marshmallow) (API Level 23)
- Compile SDK Version: 35 (Android 15)
- Required Permissions:
  - android.permission.INTERNET (Required for network operations)
  - android.permission.POST_NOTIFICATIONS
  - android.permission.FOREGROUND_SERVICE_SPECIAL_USE
  - android.permission.FOREGROUND_SERVICE_PHONE_CALL
  - android.permission.FOREGROUND_SERVICE_MICROPHONE
  - android.permission.MANAGE_OWN_CALLS
  - android.hardware.sensor.proximity
  - android.permission.BLUETOOTH_CONNECT
  - android.permission.USE_FULL_SCREEN_INTENT
  - android.permission.MODIFY_AUDIO_SETTINGS
  - android.permission.SYSTEM_ALERT_WINDOW
  - android.permission.RECORD_AUDIO
  - android.permission.VIBRATE

**iOS**: iOS 13 or above is required.

### Installation steps:

1. Add Mobilisten Calls as a dependency within the `pubspec.yaml` file as shown below.

```diff
dependencies:
  flutter:
    sdk: flutter
+ salesiq_mobilisten: ^6.5.4
+ salesiq_mobilisten_calls: ^0.0.2
```

2. Run `flutter pub get` to fetch dependencies for the project.

3. Navigate to the `ios` directory and run the `pod install` command.

4. Add the following permissions in the **Info.plist** file for the iOS Runner project.
   ![Mobilisten iOS Permissions Info.plist](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/cordova-installation-step2.png)

5. Open the `android` directory in Android Studio or any IDE used for Android development. Open the
   project `build.gradle` or `settings.gradle` file and add the following maven repository.

For Gradle version 6.7 and below

```Gradle
// Add the following to your project's root build.gradle file.

allprojects {
   repositories {
      google()
      mavenCentral()
      // ...
      maven { url 'https://maven.zohodl.com' }
   }
}
```

For Gradle version 6.8 and above

```Gradle
// Add the following to your settings.gradle file.

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // Add the Zoho Maven URL here
        maven { url 'https://maven.zohodl.com' }
    }
}
```

<img alt class="screenshot" src="https://www.zohowebstatic.com/sites/default/files/u7370/rn1.png" alt="Mobilisten Android Gradle Sync"/>

Now, click on **Sync Now** or use the **Sync Project with Gradle Files** option under the File menu.

6. Build and run the flutter application on Android and iOS.

## API Documentation

You can find the list of all APIs and their
documentation [here](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-installation.html)
under the **API Reference** section.
