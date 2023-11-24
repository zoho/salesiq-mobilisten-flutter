class DateTimeUtils {
  static DateTime? convertDoubleToDateTime(double? epochTime) {
    return epochTime != null
        ? DateTime.fromMillisecondsSinceEpoch(epochTime.toInt())
        : null;
  }
}
