import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salesiq_mobilisten/main.dart';

void main() {
  const MethodChannel channel = MethodChannel('mobilisten_plugin');
  const EventChannel eventChannel = EventChannel('events_mobilisten_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {});
}
