import 'package:flutter/services.dart';

/// Defines the severity of a debug log message that you write with
/// [ZohoSalesIQLogger].
class Level {
  // ignore_for_file: public_member_api_docs

  const Level._(this.index);

  /// The ordinal index of the level.
  final int index;

  /// An informational message.
  static const Level info = Level._(0);

  /// A warning message.
  static const Level warning = Level._(1);

  /// An error message.
  static const Level error = Level._(2);

  /// All log levels, in order of increasing severity.
  static const List<Level> values = <Level>[info, warning, error];

  @override
  String toString() {
    return const <int, String>{0: 'INFO', 1: 'WARNING', 2: 'ERROR'}[index]!;
  }
}

/// Controls the debug logger of the SDK. With it, you can write logs, clear
/// them, and turn the logger on or off. It is a static class, so call its
/// methods directly on [ZohoSalesIQLogger].
class ZohoSalesIQLogger {
  /// The platform channel that connects to the native logger.
  static MethodChannel methodChannel =
      const MethodChannel('salesiq_mobilisten');

  /// Writes the debug log message [log] at the given severity [level].
  static Future<void> writeLogForiOS(String log, Level level) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("log", () => log);
    args.putIfAbsent("level", () => level.toString());
    await methodChannel.invokeMethod('writeLogForiOS', args);
  }

  /// Clears the debug log.
  static void clearLogsForiOS() {
    methodChannel.invokeMethod('clearLogsForiOS');
  }

  /// Returns whether the logger is enabled.
  static Future<bool> get isEnabled async {
    return await methodChannel
        .invokeMethod<bool>('isLoggerEnabled')
        .then((value) => value ?? false);
  }

  /// Turns on the logger when [enable] is `true`, and turns it off otherwise.
  static void setEnabled(bool enable) async {
    await methodChannel.invokeMethod('setLoggerEnabled', enable);
  }

  /// Sets the path in the file system where the SDK writes debug logs. Pass
  /// the path as [enable]. This works only on iOS.
  static void setPathForiOS(String enable) async {
    await methodChannel.invokeMethod('setPathForiOS', enable);
  }
}
