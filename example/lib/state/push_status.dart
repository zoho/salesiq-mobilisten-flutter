import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Normalized notification-permission state that drives the global header warning
/// (a slashed bell on every screen) and the Notifications screen. Mirrors the RN
/// `NotificationPermissionStatus`.
enum NotificationPermissionStatus { granted, denied, unknown }

/// App-wide push/notification health, so a warning indicator can live in the
/// global header (every screen) reading a single source. Designed to grow: add
/// fields here and fold them into [hasIssue] as more push failure signals become
/// available, without touching the header consumers. Mirrors the RN `pushStatus`
/// external store.
///
/// Access the shared instance via the top-level [pushStatus] singleton so the
/// header widget can read it without threading it through the widget tree.
class PushStatusStore extends ChangeNotifier {
  NotificationPermissionStatus _status = NotificationPermissionStatus.unknown;

  /// Current OS notification-permission status.
  NotificationPermissionStatus get status => _status;

  /// True when notifications need the user's attention (not granted) — drives the
  /// header warning bell. Mirrors the RN `pushHasIssue`.
  bool get hasIssue => _status != NotificationPermissionStatus.granted;

  void _set(NotificationPermissionStatus next) {
    if (_status == next) return;
    _status = next;
    notifyListeners();
  }

  /// Reads the current notification-permission status without prompting.
  ///
  /// - **Android 13+ (API 33):** reflects the runtime `POST_NOTIFICATIONS` grant.
  ///   Below API 33 `permission_handler` reports it granted (install-time).
  /// - **iOS:** reflects the `UNUserNotificationCenter` authorization.
  /// - **Other platforms:** treated as granted (nothing to warn about).
  ///
  /// Never throws — falls back to [NotificationPermissionStatus.unknown].
  Future<void> refresh() async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      _set(NotificationPermissionStatus.granted);
      return;
    }
    try {
      final status = await Permission.notification.status;
      _set(status.isGranted
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied);
    } catch (e) {
      debugPrint('[SIQ-Push] notification status check failed: $e');
      _set(NotificationPermissionStatus.unknown);
    }
  }

  /// Requests the OS notification permission the app needs to show push
  /// notifications, then publishes the resulting status.
  ///
  /// - **Android 13+:** shows the runtime `POST_NOTIFICATIONS` prompt. Below API
  ///   33 this resolves to granted without a prompt.
  /// - **iOS:** shows the system notification authorization prompt.
  ///
  /// Safe to call once at app startup, independent of SDK init. Never throws.
  Future<void> requestAndRefresh() async {
    if (!io.Platform.isAndroid && !io.Platform.isIOS) {
      _set(NotificationPermissionStatus.granted);
      return;
    }
    try {
      final result = await Permission.notification.request();
      _set(result.isGranted
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied);
    } catch (e) {
      debugPrint('[SIQ-Push] notification permission request failed: $e');
      await refresh();
    }
  }
}

/// The shared push-status store. A single instance so the global header and the
/// startup/lifecycle wiring in `main.dart` all read and write the same source.
final PushStatusStore pushStatus = PushStatusStore();
