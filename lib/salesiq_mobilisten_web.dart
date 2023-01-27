import 'dart:async';
import 'dart:js_util';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';

@JS("initZoho")
external Future _initZoho();

@JS("setHistoryVisibility")
external Future _setHistoryVisibility(String visibility);

@JS("registerVisitor")
external Future _registerVisitor(String uniqueId);

@JS("unregisterVisitor")
external Future _unRegisterVisitor();

@JS("setVisitorContactNumber")
external Future _setVisitorContactNumber(String uniqueId);

@JS("setVisitorName")
external Future _setVisitorName(String name);

@JS("setVisitorEmail")
external Future _setVisitorEmail(String email);

@JS("setDepartment")
external Future _setDepartment(String department);

@JS("setVisitorAddInfo")
external Future _setVisitorAddInfo(String key, dynamic value);

@JS("startChat")
external Future _startChat(String? question);

@JS("showFloatingWindow")
external Future _showFloatingWindow(String? message);
@JS("showFloatingButton")
external Future _showFloatingButton();
@JS("hideFloatingButton")
external Future _hideFloatingButton();
@JS("triggerFloatButtonVisibility")
external Future _triggerFloatButtonVisibility();

/// A web implementation of the SalesiqMobilistenFlutter plugin.
class MobilistenWebPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'salesiq_mobilisten',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = MobilistenWebPlugin();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  // static const String _mobilistenEventChannel = "mobilistenEventChannel";
  // static const String _mobilistenChatEventChannel =
  //     "mobilistenChatEventChannel";
  // static const String _mobilistenArticleEventChannel =
  //     "mobilistenFAQEventChannel";
  //
  // /// Stream to receive general mobilisten events.
  // static final eventChannel =
  //     EventChannel(_mobilistenEventChannel).receiveBroadcastStream();
  //
  // /// Stream to receive mobilisten events related to chat.
  // static final chatEventChannel =
  //     EventChannel(_mobilistenChatEventChannel).receiveBroadcastStream();
  //
  // /// Stream to receive events related to the knowledge base.
  // static final articleEventChannel =
  //     EventChannel(_mobilistenArticleEventChannel).receiveBroadcastStream();

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'init':
        return init();
      case 'showLauncher':
        return notImplemented(call.method);
      case 'setConversationVisibility':
        return setConversationVisibility(call.arguments as bool);
      case 'enableInAppNotification':
        return notImplemented(call.method);
      case 'enablePreChatForms':
        return notImplemented(call.method);
      case 'setChatTitle':
        return notImplemented(call.method);
      case 'unregisterVisitor':
        return unRegisterVisitor();
      case 'registerVisitor':
        return registerVisitor(call.arguments as String);
      case 'setVisitorContactNumber':
        return setVisitorContactNumber(call.arguments as String);
      case 'setVisitorName':
        return setVisitorName(call.arguments as String);
      case 'setVisitorEmail':
        return setVisitorEmail(call.arguments as String);
      case 'setVisitorNameVisibility':
        return notImplemented(call.method);
      case 'setDepartment':
        return setDepartment(call.arguments as String);
      case 'setVisitorAddInfo':
        return setVisitorAddInfo(call.arguments);
      case 'setPageTitle':
        return notImplemented(call.method);
      case 'startChat':
        return startChat(call.arguments as String?);
      case 'show':
        return startChat(null);
      case 'showFloatingWindow':
        return showFloatingWindow(call.arguments as String?);
      case 'triggerFloatButtonVisibility':
        return triggerFloatButtonVisibility();
      case 'showFloatingButton':
        return showFloatingButton();
      case 'hideFloatingButton':
        return hideFloatingButton();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'salesiq_mobilisten_flutter for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<void> init() async {
    final promise = _initZoho();
    return await promiseToFuture(promise);
  }

  String notImplemented(String nameOfFunc) {
    return "$nameOfFunc not supported on web";
  }

  Future<void> setConversationVisibility(bool show) async {
    final promise = _setHistoryVisibility(show ? "show" : "hide");
    return await promiseToFuture(promise);
  }

  Future<void> registerVisitor(String uniqueId) async {
    final promise = _registerVisitor(uniqueId);
    return await promiseToFuture(promise);
  }

  Future<void> unRegisterVisitor() async {
    final promise = _unRegisterVisitor();
    return await promiseToFuture(promise);
  }

  Future<void> setVisitorContactNumber(String number) async {
    final promise = _setVisitorContactNumber(number);
    return await promiseToFuture(promise);
  }

  Future<void> setVisitorName(String name) async {
    final promise = _setVisitorName(name);
    return await promiseToFuture(promise);
  }

  Future<void> setVisitorEmail(String email) async {
    final promise = _setVisitorEmail(email);
    return await promiseToFuture(promise);
  }

  Future<void> setDepartment(String department) async {
    final promise = _setDepartment(department);
    return await promiseToFuture(promise);
  }

  Future<void> setVisitorAddInfo(info) async {
    final promise = _setVisitorAddInfo(info['key'], info['value']);
    return await promiseToFuture(promise);
  }

  Future<void> startChat(String? question) async {
    final promise = _startChat(question ?? "");
    return await promiseToFuture(promise);
  }

  Future<void> showFloatingWindow(String? message) async {
    final promise = _showFloatingWindow(message);
    return await promiseToFuture(promise);
  }

  Future<void> triggerFloatButtonVisibility() async {
    final promise = _triggerFloatButtonVisibility();
    return await promiseToFuture(promise);
  }

  Future<void> showFloatingButton() async {
    final promise = _showFloatingButton();
    return await promiseToFuture(promise);
  }

  Future<void> hideFloatingButton() async {
    final promise = _hideFloatingButton();
    return await promiseToFuture(promise);
  }
}
