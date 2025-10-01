[![SupportedLanguages](https://img.shields.io/badge/Platforms-iOS%20%7C%20%20Android-green.svg)](https://flutter.dev/) [![Version](https://img.shields.io/badge/version-6.5.3-blue.svg)](https://mobilisten.io/)

# Zoho SalesIQ Mobilisten Flutter Plugin

Connect with customers at every step of their journey. Give them the best in-app live chat experience with Mobilisten. Mobilisten enables customers to reach you from any screen on your app, get their questions answered, and make better purchase decisions.

>__**Note**__
>Zoho SalesIQ is GDPR Compliant! The configurations for the website and Mobile SDK remain the same; if you have already configured on your site, it will be automatically reflected in Mobile SDK. If not, then [learn how to configure](https://www.zoho.com/salesiq/help/portal-settings-enable-gdpr.html) now.

## Installation:
Please follow the steps mentioned below to install the Mobilisten plugin in your Flutter mobile application.

### Requirements
**Android**:
Ensure that your project meets the following requirements:

- Minimum Android Version: Android 6.0 (Marshmallow) (API Level 23)
- Compile SDK Version: 35 (Android 15)
- Required Permissions:
   - android.permission.INTERNET (Required for network operations)

**iOS**: iOS 13 or above is required.

### Installation steps:
1. Add Mobilisten as a dependency within the `pubspec.yaml` file as shown below.
```diff
dependencies:
  flutter:
    sdk: flutter
+ salesiq_mobilisten: ^6.5.3

// Add this only if you want to integrate Mobilisten Calls along with Mobilisten
+ salesiq_mobilisten_calls: ^0.0.2
```

Refer to
this [README](https://github.com/zoho/salesiq-mobilisten-flutter/tree/main/packages/calls/README.md)
for more details with calls integration

2. Run `flutter pub get` to fetch dependencies for the project.

3. Navigate to the `ios` directory and run the `pod install` command.

4. Add the following permissions in the **Info.plist** file for the iOS Runner project.
   ![Mobilisten iOS Permissions Info.plist](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/cordova-installation-step2.png)

5. Open the `android` directory in Android Studio or any IDE used for Android development.  Open the project `build.gradle` or `settings.gradle` file and add the following maven repository.

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

6. #### Proguard rules:
If you have enabled ProGuard(minifyEnabled) R8, then please add the following rules in your `proguard-rules.pro` file in your `project/android` folder.
```
-dontwarn kotlinx.parcelize.Parcelize
```

7. Generate the App and Access keys for iOS to initialize Mobilisten. In the Zoho SalesIQ console, navigate to `Settings` → `Brands` → `Installation` → `iOS`. Enter the bundle ID for the application as shown in the below example and Click on **Generate**.
   ![iOS Mobilisten Generating App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/ios-rc1.png)
   Note the App and Access keys generated for iOS to be used in further steps.
   ![iOS Mobilisten Copy App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/ios-rc2.png)

8. Generate the App and Access keys for Android to initialize Mobilisten. In the Zoho SalesIQ console, navigate to `Settings` → `Brands` → `Installation` → `Android`. Enter the bundle ID for the application as shown in the below example and Click on **Generate**.
   ![Android Mobilisten Generating App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/android-rc1.png)
   Note the App and Access keys generated for Android to be used in further steps.
   ![Android Mobilisten Copy App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/android-rc2.png)

9. Open the **main.dart** file inside the `lib` directory and import Mobilisten as shown below. With this, additionally import `dart:io` to check the current platform which will be used at a later stage.
```dart
import 'dart:io' as io;
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
```

10. Initialize Mobilisten using the [
    `initialize`](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-initialize.html)
    API within the `initState()` method in the **main.dart** file.
```dart
if (io.Platform.isIOS || io.Platform.isAndroid) {
    String appKey;
    String accessKey;
    if (io.Platform.isIOS) {
        appKey = "INSERT_IOS_APP_KEY";
        accessKey = "INSERT_IOS_ACCESS_KEY";
    } else {
        appKey = "INSERT_ANDROID_APP_KEY";
        accessKey = "INSERT_ANDROID_ACCESS_KEY";
    }
SalesIQConfiguration configuration =
SalesIQConfiguration(appKey: appKey, accessKey: accessKey)
ZohoSalesIQ.initialize(configuration).then((_) {
        // initialization successful
        ZohoSalesIQ.launcher.show(VisibilityMode.always); // Invoking Launcher.show() is optional.
    }).catchError((error) {
        // initialization failed
        print(error);
    });
}
```
11. Build and run the flutter application on Android and iOS.

## API Documentation

You can find the list of all APIs and their documentation [here](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-installation.html) under the **API Reference** section.
