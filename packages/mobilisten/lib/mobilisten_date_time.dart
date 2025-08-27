class DateTimeUtils {
  // ignore_for_file: public_member_api_docs

  static DateTime? convertDoubleToDateTime(double? epochTime) {
    return epochTime != null
        ? DateTime.fromMillisecondsSinceEpoch(epochTime.toInt())
        : null;
  }
}
