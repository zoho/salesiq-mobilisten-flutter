/// Provides helper methods that safely cast `dynamic` values from native maps.
class PrimitiveTypeCastUtils {
  /// Converts a dynamic value to an int.
  static int? toInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    } else if (value is double) {
      return value.toInt();
    } else if (value is num) {
      return value.toInt();
    }
    return null;
  }

  /// Converts a dynamic value to an int. Returns `0` when the value cannot be
  /// converted.
  static int toIntOrZero(dynamic value) {
    final int? result = toInt(value);
    return result ?? 0;
  }

  /// Converts a dynamic value to a double.
  static double? toDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Converts a dynamic value to a bool.
  static bool? toBool(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }
}
