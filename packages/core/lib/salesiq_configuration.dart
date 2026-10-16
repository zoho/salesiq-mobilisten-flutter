// ignore_for_file: public_member_api_docs

import 'salesiq_font.dart';

/// Holds the configuration that initializes the SDK and manages its settings in
/// your Flutter app. It is part of the core package of the SalesIQ Flutter
/// plugin. It includes the App Key, the Access Key, and an optional call view
/// mode.
///
/// Parameters:
/// - [appKey]: The unique App Key that is generated in SalesIQ.
/// - [accessKey]: The Access Key of the brand.
/// - [androidCallViewMode]: An optional parameter that sets the call view mode.
/// - [fonts]: Optional custom fonts for the SDK's UI. This works only on
///   Android.
class SalesIQConfiguration {
  final String appKey;
  final String accessKey;
  final SalesIQCallViewMode? androidCallViewMode;

  /// Custom fonts for the SDK's UI.
  ///
  /// This works only on Android. The iOS SDK does not support setting fonts
  /// through the SDK, so iOS ignores this value.
  final SalesIQFont? fonts;

  const SalesIQConfiguration(
      {required this.appKey,
      required this.accessKey,
      this.androidCallViewMode,
      this.fonts});

  SalesIQConfiguration copyWith({
    SalesIQCallViewMode? callViewMode,
    SalesIQFont? fonts,
  }) {
    return SalesIQConfiguration(
      appKey: appKey,
      accessKey: accessKey,
      androidCallViewMode: callViewMode ?? androidCallViewMode,
      fonts: fonts ?? this.fonts,
    );
  }
}

/// Defines how the call view appears on Android during a call.
enum SalesIQCallViewMode {
  /// The call appears as a banner at the top of the screen.
  banner,

  /// The call appears in a floating window that the visitor can drag.
  floating
}
