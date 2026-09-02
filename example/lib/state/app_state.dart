import 'package:flutter/foundation.dart';

import '../theme/theme.dart';
import 'events.dart';

/// The SDK's automatic-init lifecycle, surfaced as status-only UI (no manual
/// init buttons anywhere). Mirrors the RN `initStatus`.
enum InitStatus { initializing, initialized, keysRequired, failed }

/// Placeholder keys shipped with the sample. When the stored keys still match a
/// placeholder, the app shows the graceful "keys required" state instead of
/// attempting to initialize. Replace these in [AppState] or via Settings.
const String kPlaceholderAndroidAppKey =
    'INSERT_ANDROID_APP_KEY';
const String kPlaceholderAndroidAccessKey =
    'INSERT_ANDROID_ACCESS_KEY';
const String kPlaceholderIosAppKey = 'INSERT_IOS_APP_KEY';
const String kPlaceholderIosAccessKey = 'INSERT_IOS_ACCESS_KEY';

/// Returns true when either key is empty or still a `<PLACEHOLDER>`.
bool hasPlaceholderKeys(String appKey, String accessKey) {
  bool isPlaceholder(String v) =>
      v.trim().isEmpty ||
      v.startsWith('INSERT_') ||
      (v.startsWith('<') && v.endsWith('>'));
  return isPlaceholder(appKey) || isPlaceholder(accessKey);
}

/// App-wide reactive state: theme override, captured events, and the SDK init
/// status + credentials. A single instance is created in `main` and shared via
/// an [InheritedWidget].
class AppState {
  final AppTheme theme = AppTheme();
  final EventStore events = EventStore();
  final ValueNotifier<InitStatus> initStatus =
      ValueNotifier<InitStatus>(InitStatus.initializing);

  /// The effective keys used for this run (set once at startup).
  String appKey = '';
  String accessKey = '';

  /// Draft keys saved from Settings; applied on next launch (the native SDK
  /// initializes once, at startup).
  String? pendingAppKey;
  String? pendingAccessKey;

  void dispose() {
    theme.dispose();
    events.dispose();
    initStatus.dispose();
  }
}
