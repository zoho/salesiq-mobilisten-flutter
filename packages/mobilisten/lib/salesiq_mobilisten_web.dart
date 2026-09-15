import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// Web implementation of Mobilisten.
///
/// Mobilisten itself has no web SDK. On the web, Zoho SalesIQ is delivered as
/// the regular website chat widget, driven through the `$zoho.salesiq`
/// JavaScript API. This plugin answers the same method channels the Dart side
/// already talks to and forwards the supported calls to that JavaScript API, so
/// application code can keep calling [ZohoSalesIQ] unchanged.
///
/// The widget is loaded on the first `init` call. Because the website widget
/// uses a *widget code* rather than the Mobilisten app key/access key, supply it
/// in one of these ways, checked in order:
///
/// 1. a `widgetCode` entry in the `init` arguments;
/// 2. `window.zohoSalesIQWidgetCode`, set from `web/index.html`;
/// 3. the `appKey` passed to `ZohoSalesIQ.init` — i.e. call
///    `ZohoSalesIQ.init(<widget code>, <data centre host>)` on web, in which
///    case the `accessKey` position carries the host.
///
/// The data centre host defaults to `salesiq.zohopublic.com` and can be
/// overridden with a `domain` argument or `window.zohoSalesIQDomain` (for
/// example `salesiq.zohopublic.eu`). The `accessKey` position is only read as a
/// host when the widget code also came from `appKey`, so passing genuine
/// Mobilisten credentials alongside a widget code declared on `window` cannot
/// corrupt the widget URL.
///
/// Calls that have no website equivalent — launcher geometry, native themes,
/// push notifications, the knowledge base and conversation modules — are
/// accepted and ignored rather than raising `MissingPluginException`.
class MobilistenWebPlugin {
  /// Registers the web implementation with the Flutter web plugin registry.
  static void registerWith(Registrar registrar) {
    final plugin = MobilistenWebPlugin();

    MethodChannel(_mainChannel, const StandardMethodCodec(), registrar)
        .setMethodCallHandler(plugin.handleMainCall);

    MethodChannel(_launcherChannel, const StandardMethodCodec(), registrar)
        .setMethodCallHandler(plugin.handleLauncherCall);

    for (final name in _ignoredChannels) {
      MethodChannel(name, const StandardMethodCodec(), registrar)
          .setMethodCallHandler(plugin._ignore);
    }
  }

  static const _mainChannel = 'salesiq_mobilisten';
  static const _launcherChannel = 'salesiq_launcher_module';

  /// Channels whose features the website widget does not expose. They are
  /// registered purely so calls resolve to `null` instead of throwing.
  static const _ignoredChannels = <String>[
    'salesiq_chat_module',
    'salesiq_knowledge_base',
    'salesiq_conversations_module',
    'salesiqNotificationModule',
  ];

  static const _defaultDomain = 'salesiq.zohopublic.com';
  static const _scriptId = 'zsiqscript';

  /// Index of `VisibilityMode.never`, the only mode that hides the launcher.
  static const _visibilityModeNever = 1;

  bool _widgetRequested = false;
  bool _widgetReady = false;
  final List<void Function()> _pendingCalls = <void Function()>[];

  /// Handles calls on the main `salesiq_mobilisten` channel.
  Future<dynamic> handleMainCall(MethodCall call) async {
    switch (call.method) {
      case 'init':
        await _loadWidget(_argumentMap(call.arguments));
        return null;

      case 'setVisitorName':
        _whenReady(() => _setVisitorName(call.arguments as String?));
        return null;

      case 'setVisitorEmail':
        final email = call.arguments as String?;
        if (email != null && email.isNotEmpty) {
          _whenReady(() => _invoke('visitor.email', <JSAny?>[email.toJS]));
        }
        return null;

      case 'setLanguage':
        final language = call.arguments as String?;
        if (language != null && language.isNotEmpty) {
          _whenReady(() => _invoke('language', <JSAny?>[language.toJS]));
        }
        return null;

      case 'setQuestion':
        final question = call.arguments as String?;
        if (question != null && question.isNotEmpty) {
          _whenReady(() => _invoke('chat.question', <JSAny?>[question.toJS]));
        }
        return null;

      case 'startChat':
        final question = call.arguments as String?;
        _whenReady(() {
          if (question != null && question.isNotEmpty) {
            _invoke('chat.question', <JSAny?>[question.toJS]);
          }
          _invoke('floatwindow.visible', <JSAny?>['show'.toJS]);
        });
        return null;

      case 'showLauncher':
        final show = call.arguments as bool? ?? true;
        _whenReady(() => _setLauncherVisible(show));
        return null;

      // `present` and `show` both open the chat UI.
      case 'present':
      case 'show':
        _whenReady(() => _invoke('floatwindow.visible', <JSAny?>['show'.toJS]));
        return true;

      case 'dismissUI':
        _whenReady(() => _invoke('floatwindow.visible', <JSAny?>['hide'.toJS]));
        return null;

      // `reset` clears cookies, ends open chats and drops every value set
      // through the JS API, which is what unregistering a visitor means here.
      case 'unregisterVisitor':
        _whenReady(() => _invoke('reset', const <JSAny?>[]));
        return null;

      default:
        return null;
    }
  }

  /// Handles calls on the `salesiq_launcher_module` channel.
  Future<dynamic> handleLauncherCall(MethodCall call) async {
    if (call.method != 'show') return null;

    final mode = _argumentMap(call.arguments)['visibility_mode'];
    _whenReady(() => _setLauncherVisible(mode != _visibilityModeNever));
    return null;
  }

  Future<dynamic> _ignore(MethodCall call) async => null;

  /// Injects the SalesIQ widget script and arranges for queued calls to run
  /// once it signals readiness. Subsequent calls are no-ops.
  Future<void> _loadWidget(Map<Object?, Object?> arguments) async {
    if (_widgetRequested) return;

    var widgetCode = _string(arguments['widgetCode']) ??
        _windowString('zohoSalesIQWidgetCode');

    // Only when the widget code itself was passed positionally does the
    // `accessKey` position mean the data centre host.
    String? positionalDomain;
    if (widgetCode == null) {
      widgetCode = _string(arguments['appKey']);
      positionalDomain = _string(arguments['accessKey']);
    }

    if (widgetCode == null || widgetCode.isEmpty) {
      throw PlatformException(
        code: 'missing_widget_code',
        message: 'No Zoho SalesIQ widget code was supplied. Pass it as the '
            'appKey to ZohoSalesIQ.init, as a widgetCode argument, or set '
            'window.zohoSalesIQWidgetCode in web/index.html.',
      );
    }

    _widgetRequested = true;

    final domain = _string(arguments['domain']) ??
        _windowString('zohoSalesIQDomain') ??
        positionalDomain ??
        _defaultDomain;

    // The widget expects `$zoho.salesiq` to exist before its script runs, and
    // invokes `ready` once the API is usable. Anything the app asked for in the
    // meantime is replayed at that point.
    final salesIQ = _ensureNamespace();
    salesIQ.setProperty('ready'.toJS, _flushPendingCalls.toJS);

    if (web.document.getElementById(_scriptId) == null) {
      final script = web.HTMLScriptElement()
        ..id = _scriptId
        ..src = 'https://$domain/widget?wc=$widgetCode'
        ..defer = true;
      web.document.body?.append(script);
    }
  }

  void _flushPendingCalls() {
    _widgetReady = true;
    final calls = List<void Function()>.of(_pendingCalls);
    _pendingCalls.clear();
    for (final call in calls) {
      call();
    }
  }

  /// Runs [action] now if the widget is ready, otherwise queues it.
  void _whenReady(void Function() action) {
    if (_widgetReady) {
      action();
    } else {
      _pendingCalls.add(action);
    }
  }

  void _setLauncherVisible(bool visible) {
    _invoke(
      'floatbutton.visible',
      <JSAny?>[visible ? 'show'.toJS : 'hide'.toJS],
    );
  }

  /// The website API takes a name object rather than the single string the
  /// Mobilisten API uses, so the first whitespace-separated token becomes the
  /// first name and the remainder the last name.
  void _setVisitorName(String? name) {
    final fullName = (name ?? '').trim();
    if (fullName.isEmpty) return;

    final parts = fullName.split(RegExp(r'\s+'));
    final payload = JSObject()..setProperty('firstname'.toJS, parts.first.toJS);
    if (parts.length > 1) {
      payload.setProperty('lastname'.toJS, parts.skip(1).join(' ').toJS);
    }

    _invoke('visitor.name', <JSAny?>[payload]);
  }

  /// Calls a dot-separated [path] such as `visitor.email` under
  /// `$zoho.salesiq`, doing nothing if the widget has not defined it.
  void _invoke(String path, List<JSAny?> arguments) {
    final segments = path.split('.');

    JSObject? target = _salesIQ;
    for (final segment in segments.take(segments.length - 1)) {
      target = target?.getProperty<JSObject?>(segment.toJS);
    }

    final method = segments.last;
    if (target == null || !target.has(method)) return;

    switch (arguments.length) {
      case 0:
        target.callMethod<JSAny?>(method.toJS);
      case 1:
        target.callMethod<JSAny?>(method.toJS, arguments[0]);
      default:
        target.callMethod<JSAny?>(method.toJS, arguments[0], arguments[1]);
    }
  }

  /// `$zoho.salesiq`, or `null` before the namespace exists. Read fresh on each
  /// access because the widget script replaces parts of it as it loads.
  JSObject? get _salesIQ => globalContext
      .getProperty<JSObject?>(r'$zoho'.toJS)
      ?.getProperty<JSObject?>('salesiq'.toJS);

  /// Creates `$zoho.salesiq` if the page has not already declared it.
  JSObject _ensureNamespace() {
    var zoho = globalContext.getProperty<JSObject?>(r'$zoho'.toJS);
    if (zoho == null) {
      zoho = JSObject();
      globalContext.setProperty(r'$zoho'.toJS, zoho);
    }

    var salesIQ = zoho.getProperty<JSObject?>('salesiq'.toJS);
    if (salesIQ == null) {
      salesIQ = JSObject();
      zoho.setProperty('salesiq'.toJS, salesIQ);
    }

    return salesIQ;
  }

  String? _windowString(String property) =>
      _string(globalContext.getProperty<JSString?>(property.toJS)?.toDart);

  String? _string(Object? value) {
    if (value is! String) return null;
    return value.isEmpty ? null : value;
  }

  Map<Object?, Object?> _argumentMap(Object? arguments) =>
      arguments is Map ? arguments : const <Object?, Object?>{};
}
