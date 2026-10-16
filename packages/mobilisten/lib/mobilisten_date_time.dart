/// Provides helper methods that convert native epoch timestamps to [DateTime].
class DateTimeUtils {
  // ignore_for_file: public_member_api_docs

  /// Converts [epochTime], in milliseconds since the epoch, to a [DateTime].
  /// Returns `null` when [epochTime] is `null`.
  static DateTime? convertDoubleToDateTime(double? epochTime) {
    return epochTime != null
        ? DateTime.fromMillisecondsSinceEpoch(epochTime.toInt())
        : null;
  }
}
