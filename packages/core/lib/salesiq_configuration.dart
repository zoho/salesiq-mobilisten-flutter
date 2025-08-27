/// This file is part of the core package for the SalesIQ Flutter plugin.
/// It contains the configuration class for SalesIQ, which includes
/// the app key, access key, and optional call view mode.
/// The SalesIQConfiguration class is used to initialize
/// and manage the configuration settings for SalesIQ in a Flutter application.
/// Parameters:
/// - [appKey]: The unique key for the generated in SalesIQ.
/// - [accessKey]: The access key for the brand.
/// - [androidCallViewMode]: Optional parameter to set the call view mode.
class SalesIQConfiguration {
  final String appKey;
  final String accessKey;
  final SalesIQCallViewMode? androidCallViewMode;

  const SalesIQConfiguration(
      {required this.appKey,
      required this.accessKey,
      this.androidCallViewMode});

  SalesIQConfiguration copyWith({
    SalesIQCallViewMode? callViewMode,
  }) {
    return SalesIQConfiguration(
      appKey: appKey,
      accessKey: accessKey,
      androidCallViewMode: callViewMode,
    );
  }
}

enum SalesIQCallViewMode { banner, floating }
