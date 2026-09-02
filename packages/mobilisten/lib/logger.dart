import 'package:flutter/services.dart';

/// The severity of a debug log message written through [ZohoSalesIQLogger].
class Level {
  // ignore_for_file: public_member_api_docs

  const Level._(this.index);

  /// The ordinal index of the level.
  final int index;

  /// Informational message.
  static const Level info = Level._(0);

  /// Warning message.
  static const Level warning = Level._(1);

  /// Error message.
  static const Level error = Level._(2);

  /// All log levels, ordered by increasing severity.
  static const List<Level> values = <Level>[info, warning, error];

  @override
  String toString() {
    return const <int, String>{0: 'INFO', 1: 'WARNING', 2: 'ERROR'}[index]!;
  }
}

/// Controls Mobilisten's debug logger — writing, clearing and enabling log
/// output. Accessed via [ZohoSalesIQ.logger].
class ZohoSalesIQLogger {
  /// The platform channel used to reach the native logger.
  static MethodChannel methodChannel =
      const MethodChannel('salesiq_mobilisten');

  /// Writes the debug log message [log] at the given severity [level].
  static Future<void> writeLogForiOS(String log, Level level) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("log", () => log);
    args.putIfAbsent("level", () => level.toString());
    await methodChannel.invokeMethod('writeLogForiOS', args);
  }

  /// Use this API to clear the Debug log
  static void clearLogsForiOS() {
    methodChannel.invokeMethod('clearLogsForiOS');
  }

  /// returns a boolean value that is used to determine whether the logger is enabled or not.
  static Future<bool> get isEnabled async {
    return await methodChannel
        .invokeMethod<bool>('isLoggerEnabled')
        .then((value) => value ?? false);
  }

  /// Enables the logger when [enable] is `true`, otherwise disables it.
  static void setEnabled(bool enable) async {
    await methodChannel.invokeMethod('setLoggerEnabled', enable);
  }

  /// Sets the file-system path, [enable], to which debug logs are written.
  static void setPathForiOS(String enable) async {
    await methodChannel.invokeMethod('setPathForiOS', enable);
  }
}
