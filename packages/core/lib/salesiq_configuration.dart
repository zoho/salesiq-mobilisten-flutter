// ignore_for_file: public_member_api_docs

import 'salesiq_font.dart';

/// This file is part of the core package for the SalesIQ Flutter plugin.
/// It contains the configuration class for SalesIQ, which includes
/// the app key, access key, and optional call view mode.
/// The SalesIQConfiguration class is used to initialize
/// and manage the configuration settings for SalesIQ in a Flutter application.
/// Parameters:
/// - [appKey]: The unique key for the generated in SalesIQ.
/// - [accessKey]: The access key for the brand.
/// - [androidCallViewMode]: Optional parameter to set the call view mode.
/// - [fonts]: Optional custom fonts for the Mobilisten UI (Android only).
class SalesIQConfiguration {
  final String appKey;
  final String accessKey;
  final SalesIQCallViewMode? androidCallViewMode;

  /// Custom fonts for the Mobilisten UI.
  ///
  /// Applies only on Android; the iOS native SDK does not support configuring
  /// fonts through the SDK, so this value is ignored on iOS.
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

/// How the in-call view is presented on Android.
enum SalesIQCallViewMode {
  /// The call is shown as a banner docked at the top of the screen.
  banner,

  /// The call is shown in a floating, draggable window.
  floating
}
