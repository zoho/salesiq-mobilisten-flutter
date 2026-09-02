// ignore_for_file: public_member_api_docs

/// Custom fonts to be used inside the Mobilisten UI.
///
/// Note: Wired through the native configuration on Android; the iOS
/// native SDK has no equivalent configuration hook.
class SalesIQFont {
  SalesIQFontType? regular = null, medium = null;
}

/// A single custom font, referenced by the [path] to its font file, used
/// within the Mobilisten UI.
class SalesIQFontType {
  /// The file-system path to the font resource.
  String? path = null;

  /// Creates a [SalesIQFontType] for the font at the given [path].
  SalesIQFontType(this.path);
}
