[![SupportedLanguages](https://img.shields.io/badge/Platforms-iOS%20%7C%20%20Android-green.svg)](https://flutter.dev/) [![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://mobilisten.io/)

# Zoho SalesIQ Mobilisten Flutter Plugin

Connect with customers at every step of their journey. Give them the best in-app live chat experience with Mobilisten. Mobilisten enables customers to reach you from any screen on your app, get their questions answered, and make better purchase decisions.  

>__**Note**__
>Zoho SalesIQ is GDPR Compliant! The configurations for the website and Mobile SDK remain the same; if you have already configured on your site, it will be automatically reflected in Mobile SDK. If not, then [learn how to configure](https://www.zoho.com/salesiq/help/portal-settings-enable-gdpr.html) now.

## Installation:
Please follow the steps mentioned below to install the Mobilisten plugin in your Flutter mobile application.

### Requirements
**Android**: `minSdkVersion` 14 and above is required.

**iOS**: iOS 10 or above is required. The minimum version of Xcode required is Xcode 12.

### Installation steps:
1. Create a Flutter project named **`mobilisten_demo`** using the flutter CLI.
```bash
flutter create --org com.zylker  mobilisten_demo
```

2. Change the working directory of the terminal to the project that has been created.
```bash
cd mobilisten_demo
```

3. Add Mobilisten as a dependency within the `pubspec.yaml` file as shown below.
```diff
dependencies:
  flutter:
    sdk: flutter
+   mobilisten_plugin: 
+      git: https://github.com/zoho/salesiq-mobilisten-flutter
```

4. Run the following command from the terminal.
```bash
flutter pub get
```

5. Run the following command to upgrade all dependencies to the latest version.
```bash
flutter pub upgrade
```
6. For iOS, Add the following permissions in the **Info.plist** file in the `ios/Runner` directory.
![Mobilisten iOS Permissions Info.plist](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/cordova-installation-step2.png)

7. Open the `android` directory in Android Studio or any IDE used for Android development.  Open the project **build.gradle** file and add the following maven repository.
```groovy
allprojects {
    repositories {
        .....
        maven { url 'https://maven.zohodl.com' }
    }
}
```
<img alt class="screenshot" src="https://www.zohowebstatic.com/sites/default/files/u7370/rn1.png" alt="Mobilisten Android Gradle Sync" style="width:250px; height:auto;"/>

Now, click on **Sync Now** or use the **Sync Project with Gradle Files** option under the File menu.

8.  Generate the App and Access keys for iOS to initialize Mobilisten. In the Zoho SalesIQ console, navigate to `Settings` → `Brands` → `Installation` → `iOS`. Enter the bundle ID for the application as shown in the below example and Click on **Generate**.
![iOS Mobilisten Generating App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/ios-rc1.png)
Note the App and Access keys generated for iOS to be used in further steps.
![iOS Mobilisten Copy App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/ios-rc2.png)

9.  Generate the App and Access keys for Android to initialize Mobilisten. In the Zoho SalesIQ console, navigate to `Settings` → `Brands` → `Installation` → `Android`. Enter the bundle ID for the application as shown in the below example and Click on **Generate**.
![Android Mobilisten Generating App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/android-rc1.png)
Note the App and Access keys generated for Android to be used in further steps.
![Android Mobilisten Copy App and Access Keys](https://www.zohowebstatic.com/sites/default/files/u71249/SDK2/android-rc2.png)

10. Open the **main.dart** file inside the `lib` directory and import Mobilisten as shown below. With this, additionally import `dart:io` to check the current platform which will be used at a later stage.
```dart
import 'dart:io' as io;
import 'package:mobilisten_plugin/mobilisten_plugin.dart';
```

11. Initialize Mobilisten using the [`init`](https://zcms.zohocorp.com/salesiq/help/developer-guides/flutter-sdk-init.html) API within the `initState()` method in the **main.dart** file.
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
    ZohoSalesIQ.init(appKey, accessKey).then((_) {
        // initialization successful
        ZohoSalesIQ.showLauncher(true); // Invoking showLauncher is optional.
    }).catchError((error) {
        // initialization failed
        print(error);
    });
}
```
12. Build and run the flutter application on Android and iOS.

## API Documentation

You can find the list of all APIs and their documentation  [here](https://zcms.zohocorp.com/salesiq/help/developer-guides/flutter-sdk-show-launcher.html)  under the  **API Reference**  section.
