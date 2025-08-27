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
