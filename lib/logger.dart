import 'package:flutter/services.dart';

class Level {
  // ignore_for_file: public_member_api_docs

  const Level._(this.index);

  final int index;

  static const Level info = Level._(0);
  static const Level warning = Level._(1);
  static const Level error = Level._(2);

  static const List<Level> values = <Level>[info, warning, error];

  @override
  String toString() {
    return const <int, String>{0: 'INFO', 1: 'WARNING', 2: 'ERROR'}[index]!;
  }
}

class ZohoSalesIQLogger {
  static MethodChannel methodChannel =
      const MethodChannel('salesiq_mobilisten');

  /// Use this API to write the Debug log with log type
  static Future<Null> writeLogForiOS(String log, Level level) async {
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

  /// Sets the logger to be enabled when true is set else it'll be disabled.
  static void setEnabled(bool enable) async {
    await methodChannel.invokeMethod('setLoggerEnabled', enable);
  }

  /// Sets the path for write the Debug log
  static void setPathForiOS(String enable) async {
    await methodChannel.invokeMethod('setPathForiOS', enable);
  }
}
