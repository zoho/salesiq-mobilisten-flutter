// ignore_for_file: public_member_api_docs

/// Defines the custom fonts that the SDK uses in its UI.
///
/// This works only on Android, through the native configuration. The iOS SDK
/// has no matching configuration option.
class SalesIQFont {
  SalesIQFontType? regular = null, medium = null;
}

/// A single custom font that the SDK uses in its UI. It refers to its font file
/// by [path].
class SalesIQFontType {
  /// The path of the font resource in the file system.
  String? path = null;

  /// Creates a [SalesIQFontType] for the font at the given [path].
  SalesIQFontType(this.path);
}
