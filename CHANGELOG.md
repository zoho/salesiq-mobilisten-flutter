## Mobilisten Plugin Changelog

### 2.2.0 - 5 May 2023

- Experience the brand new version of Android
  SDK [5.0.0](https://github.com/zoho/salesiq-mobilisten-android-sample/releases/tag/v5.0.0).
- Addressed the GitHub issues - [#30](https://github.com/zoho/salesiq-mobilisten-flutter/issues/30)
  , [#31](https://github.com/zoho/salesiq-mobilisten-flutter/issues/31)
  , [#32](https://github.com/zoho/salesiq-mobilisten-flutter/issues/32).
- lastMessage, lastMessageSender and lastMessageTime
  in [getChats()](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-chat-getchats.html)
  and [getChatsWithFilter()](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-getChatsWithFilter.html)
  APIs is deprecated. Use recentMessage instead.

### 2.1.2 - 13 Apr 2023

- Updated Mobilisten SDK for iOS to
  version [5.3.2](https://github.com/zoho/SalesIQ-Mobilisten-iOS/releases/tag/v5.3.2).

### 2.1.1 - 29 Mar 2023

- Updated Mobilisten SDK for iOS to
  version [5.3.1](https://github.com/zoho/SalesIQ-Mobilisten-iOS/releases/tag/v5.3.1).

### 2.1.0 - 13 Mar 2023

- Updated Mobilisten SDK for iOS to
  version [5.3.0](https://github.com/zoho/SalesIQ-Mobilisten-iOS/releases/tag/v5.3.0) and Android to
  version [4.4.0](https://github.com/zoho/salesiq-mobilisten-android-sample/releases/tag/v4.4.0).
- Added support for Georgian [ka], Armenian [hy], and Persian [fa] languages. You can change to
  these languages using
  the [.setLanguage()](https://www.zoho.com/salesiq/help/developer-section/cordova-ionic-sdk-set-language.html)
  API.
- Addressed the GitHub issue - [#28](https://github.com/zoho/salesiq-mobilisten-flutter/issues/28).

### 2.0.0 - 03 Jan 2023

- Experience the brand new version of iOS SDK [5.0.0](https://github.com/zoho/SalesIQ-Mobilisten-iOS/releases/tag/v5.0.0) and improved Android SDK [4.3.3](https://github.com/zoho/salesiq-mobilisten-android-sample/releases/tag/v4.3.3).
- Get debug logs for your application from app users instantly with a click using new [Logger APIs](https://www.zoho.com/salesiq/help/developer-section/flutter-sdk-logger-set-enabled.html).
- Added support to change the order of tabs in SalesIQ SDK inside your mobile app using [setTabOrder()](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-set-tab-order.html).
- A new method, [shouldOpenURL()](https://www.zoho.com/salesiq/help/developer-guides/flutter-should-open-url.html) introduced to customize URL redirection.
- Implemented [setNotificationIconForAndroid()](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-notification-android.html) API.
- Implemented [sendEvent()](https://www.zoho.com/salesiq/help/developer-guides/flutter-send-event.html) API and deprecated the [completeChatAction()](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-chat-actions-completeChatAction.html) and [completeChatActionWithMessage()](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-chat-actions-completeChatActionWithMessage.html) APIs.
- Implemented [launcherProperties](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-launcher-button-customization.html) for Android to customize the SalesIQ launcher.
- Implemented the EVENT_HANDLE_URL event in [event listener](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-event-handler-chatEventChannel.html), refer [sendEvent()](https://www.zoho.com/salesiq/help/developer-guides/flutter-send-event.html) API for more details.
- Other miscellaneous bug fixes.

### 1.0.4 - 30 Aug 2022

- Updated Mobilisten SDK for Android to version 4.2.9. [Learn More about the update](https://github.com/zoho/salesiq-mobilisten-android-sample/releases/tag/v4.2.9).

### 1.0.3 - 10 Aug 2022

- Updated Mobilisten SDK for Android to version 4.2.8. [Learn More about the update](https://github.com/zoho/salesiq-mobilisten-android-sample/releases/tag/v4.2.8).
- Updated Mobilisten SDK for iOS to version 4.2.8. [Learn More about the update](https://github.com/zoho/SalesIQ-Mobilisten-iOS/releases/tag/v4.2.8).

### 1.0.2 - 21 Feb 2022

- Updated Mobilisten SDK for Android to version 4.2.3. [Learn More about the update](https://github.com/zoho/salesiq-mobilisten-android-sample/releases/tag/4.2.3).
- Updated Mobilisten SDK for iOS to version 4.2.6. [Learn More about the update](https://github.com/zoho/SalesIQ-Mobilisten-iOS/releases/tag/v4.2.6).
- Added .chatUnreadCount API to fetch the current unread count of the chats. [Learn More](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-chat-unread-count.html).
- Added chatUnreadCountChanged event in chatEventChannel to track the change in the unreadCount. [Learn More](https://www.zoho.com/salesiq/help/developer-guides/flutter-sdk-event-handler-chatEventChannel.html).

### 1.0.1 - 08 Dec 2021

- Updated Mobilisten SDK for iOS to version 4.2.3. [Learn More about the update](https://github.com/zoho/SalesIQ-Mobilisten-iOS/releases/tag/v4.2.3).
- Updated Mobilisten SDK for Android to version 4.2.1. [Learn More about the update](https://github.com/zoho/salesiq-mobilisten-android-sample/releases/tag/4.2.1).

### 1.0.0 - 30 Sep 2021

- Initial release of the plugin for the iOS and Android platforms.
