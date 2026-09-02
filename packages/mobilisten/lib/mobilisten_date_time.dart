/// Utility helpers for converting native epoch timestamps to [DateTime].
class DateTimeUtils {
  // ignore_for_file: public_member_api_docs

  /// Converts an [epochTime] in milliseconds since epoch to a [DateTime],
  /// returning `null` when [epochTime] is `null`.
  static DateTime? convertDoubleToDateTime(double? epochTime) {
    return epochTime != null
        ? DateTime.fromMillisecondsSinceEpoch(epochTime.toInt())
        : null;
  }
}
