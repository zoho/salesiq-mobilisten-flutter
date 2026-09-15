@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten_web.dart';
import 'package:web/web.dart' as web;

/// A host that can never resolve, so tests never reach a real data centre.
const _domain = 'salesiq.example.invalid';

void main() {
  late MobilistenWebPlugin plugin;
  late JSObject salesIQ;
  late List<String> calls;

  /// Installs a `$zoho.salesiq` stub that records the calls the plugin makes.
  void installStub() {
    calls = <String>[];

    void record(String name, String value) => calls.add('$name:$value');

    final visitor = JSObject()
      ..setProperty('email'.toJS,
          ((JSString v) => record('visitor.email', v.toDart)).toJS)
      ..setProperty(
          'name'.toJS,
          ((JSObject v) => record(
              'visitor.name',
              '${v.getProperty<JSString?>('firstname'.toJS)?.toDart}'
              ' ${v.getProperty<JSString?>('lastname'.toJS)?.toDart}')).toJS);

    salesIQ = JSObject()
      ..setProperty('visitor'.toJS, visitor)
      ..setProperty(
          'language'.toJS, ((JSString v) => record('language', v.toDart)).toJS)
      ..setProperty(
          'floatbutton'.toJS,
          JSObject()
            ..setProperty('visible'.toJS,
                ((JSString v) => record('floatbutton', v.toDart)).toJS))
      ..setProperty(
          'floatwindow'.toJS,
          JSObject()
            ..setProperty('visible'.toJS,
                ((JSString v) => record('floatwindow', v.toDart)).toJS))
      ..setProperty('reset'.toJS, (() => record('reset', '')).toJS);

    globalContext
        .setProperty(r'$zoho'.toJS, JSObject()..setProperty('salesiq'.toJS, salesIQ));
  }

  /// Fires the callback the widget script would fire once it has loaded.
  void signalWidgetReady() => salesIQ.callMethod<JSAny?>('ready'.toJS);

  Future<void> init({String widgetCode = 'wc-123'}) => plugin.handleMainCall(
        MethodCall('init', <String, dynamic>{
          'appKey': widgetCode,
          'accessKey': _domain,
        }),
      );

  setUp(() {
    plugin = MobilistenWebPlugin();
    web.document.getElementById('zsiqscript')?.remove();
    globalContext.delete(r'$zoho'.toJS);
    installStub();
  });

  test('init injects the widget script for the requested data centre',
      () async {
    await init();

    final script =
        web.document.getElementById('zsiqscript') as web.HTMLScriptElement?;
    expect(script, isNotNull);
    expect(script!.src, 'https://$_domain/widget?wc=wc-123');
    expect(script.defer, isTrue);
  });

  test('init injects the script only once', () async {
    await init();
    await init(widgetCode: 'wc-456');

    expect(web.document.querySelectorAll('#zsiqscript').length, 1);
  });

  test('init without a widget code throws instead of loading a bad URL',
      () async {
    expect(
      () => plugin.handleMainCall(
          const MethodCall('init', <String, dynamic>{'appKey': ''})),
      throwsA(isA<PlatformException>()
          .having((e) => e.code, 'code', 'missing_widget_code')),
    );
    expect(web.document.getElementById('zsiqscript'), isNull);
  });

  test('calls made before the widget is ready are replayed on ready',
      () async {
    await init();
    await plugin.handleMainCall(const MethodCall('setVisitorEmail', 'a@b.com'));
    await plugin.handleMainCall(const MethodCall('setLanguage', 'nl'));

    expect(calls, isEmpty, reason: 'nothing should run before ready fires');

    signalWidgetReady();

    expect(calls, <String>['visitor.email:a@b.com', 'language:nl']);
  });

  test('calls made after ready run immediately', () async {
    await init();
    signalWidgetReady();

    await plugin.handleMainCall(const MethodCall('setVisitorEmail', 'c@d.com'));

    expect(calls, <String>['visitor.email:c@d.com']);
  });

  test('a full name is split into firstname and lastname', () async {
    await init();
    signalWidgetReady();

    await plugin
        .handleMainCall(const MethodCall('setVisitorName', 'Ada Byron Lovelace'));

    expect(calls, <String>['visitor.name:Ada Byron Lovelace']);
  });

  test('a single-word name sends no lastname', () async {
    await init();
    signalWidgetReady();

    await plugin.handleMainCall(const MethodCall('setVisitorName', 'Ada'));

    expect(calls, <String>['visitor.name:Ada null']);
  });

  test('an empty name is not forwarded', () async {
    await init();
    signalWidgetReady();

    await plugin.handleMainCall(const MethodCall('setVisitorName', '   '));

    expect(calls, isEmpty);
  });

  test('VisibilityMode.never hides the float button, other modes show it',
      () async {
    await init();
    signalWidgetReady();

    // Indices match VisibilityMode.{always, never, whenActiveChat}.
    for (final mode in <int>[0, 1, 2]) {
      await plugin.handleLauncherCall(MethodCall(
          'show', <String, dynamic>{'visibility_mode': mode}));
    }

    expect(calls, <String>['floatbutton:show', 'floatbutton:hide', 'floatbutton:show']);
  });

  test('unregisterVisitor resets the widget', () async {
    await init();
    signalWidgetReady();

    await plugin.handleMainCall(const MethodCall('unregisterVisitor'));

    expect(calls, <String>['reset:']);
  });

  test('present opens the chat window and reports success', () async {
    await init();
    signalWidgetReady();

    final result = await plugin.handleMainCall(const MethodCall('present'));

    expect(result, isTrue);
    expect(calls, <String>['floatwindow:show']);
  });

  test('unmapped methods resolve to null rather than throwing', () async {
    await init();
    signalWidgetReady();

    expect(
      await plugin.handleMainCall(
          const MethodCall('setLauncherPropertiesForAndroid', <String, dynamic>{})),
      isNull,
    );
    expect(
      await plugin.handleMainCall(const MethodCall('getChatUnreadCount')),
      isNull,
    );
    expect(calls, isEmpty);
  });

  test('calls are dropped when the widget never defines the API', () async {
    globalContext.delete(r'$zoho'.toJS);
    await init();

    // The namespace the plugin created has no visitor object at all.
    final created = globalContext
        .getProperty<JSObject?>(r'$zoho'.toJS)
        ?.getProperty<JSObject?>('salesiq'.toJS);
    expect(created, isNotNull);

    await plugin.handleMainCall(const MethodCall('setVisitorEmail', 'a@b.com'));
    created!.callMethod<JSAny?>('ready'.toJS);
    // Reaching here without throwing is the assertion.
  });
}
