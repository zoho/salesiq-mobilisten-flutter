import 'package:flutter/services.dart';

// ignore_for_file: public_member_api_docs

/// Provides APIs to control the SalesIQ launcher view.
///
/// Mirrors the native `ZohoSalesIQ.Launcher` namespace. Access this via
/// [ZohoSalesIQ.launcher].
class Launcher {
  final MethodChannel _channel = const MethodChannel("salesiq_launcher_module");

  /// Broadcast stream of launcher events, scoped to the `ZohoSalesIQ.Launcher`
  /// namespace.
  ///
  /// Currently carries the custom-launcher visibility change. This is backed by
  /// a dedicated native `EventChannel` ("mobilistenLauncherEventChannel"),
  /// independent of the public [ZohoSalesIQ.eventChannel]; the generic
  /// [SIQEvent.customLauncherVisibility] event continues to be emitted on the
  /// public channel for back-compatibility.
  final Stream<LauncherEvent> eventChannel =
      EventChannel("mobilistenLauncherEventChannel")
          .receiveBroadcastStream()
          .map((event) =>
              CustomLauncherVisibilityEvent(event["visible"] as bool? ?? false));

  /// Controls the visibility of the default launcher using the given [mode].
  void show(VisibilityMode mode) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("visibility_mode", () => mode.index);
    _channel.invokeMethod('show', arguments);
  }

  /// Sets the visibility [mode] applied to a custom launcher view.
  ///
  /// A custom launcher defaults to [VisibilityMode.never], so it stays hidden
  /// until a visibility mode is set through this method.
  void setVisibilityModeToCustomLauncher(VisibilityMode mode) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("visibility_mode", () => mode.index);
    _channel.invokeMethod('setVisibilityModeToCustomLauncher', arguments);
  }

  /// Enables or disables drag-to-dismiss for the launcher, using the value
  /// provided for [enable].
  void enableDragToDismiss(bool enable) {
    _channel.invokeMethod('enableDragToDismiss', enable);
  }

  /// Sets the minimum press duration, [value] (in milliseconds), required to
  /// start dragging the launcher.
  void setMinimumPressDuration(int value) {
    _channel.invokeMethod('setMinimumPressDuration', value);
  }

  /// Enables or disables showing the operator's image on the launcher during
  /// an active chat, using the value provided for [show].
  void showOperatorImage(bool show) {
    _channel.invokeMethod('showOperatorImage', show);
  }

  /// Refreshes the launcher, bringing the launcher view to the front.
  void refreshLauncher() {
    _channel.invokeMethod('refresh');
  }
}

/// Base type for events delivered on [Launcher.eventChannel].
///
/// Each concrete event carries only the data relevant to it, so a field such as
/// [CustomLauncherVisibilityEvent.visible] can never be accessed on an
/// unrelated event. A new event is a new subclass; consumers handle events with
/// an exhaustive `switch` over this sealed type.
abstract class LauncherEvent {}

/// Emitted when the custom launcher's visibility changes.
class CustomLauncherVisibilityEvent extends LauncherEvent {
  /// Whether the custom launcher should now be visible.
  final bool visible;

  /// Creates a custom-launcher visibility event with the given [visible] state.
  CustomLauncherVisibilityEvent(this.visible);
}

/// Controls when the launcher is visible.
enum VisibilityMode {
  /// The launcher is always visible.
  always,

  /// The launcher is never visible.
  never,

  /// The launcher is visible only during an active chat.
  whenActiveChat
}

/// The layout mode of the launcher view.
class LauncherMode {
  const LauncherMode._(this.index);

  /// The ordinal index of the mode.
  final int index;

  /// A launcher fixed at a static position.
  static const LauncherMode static = LauncherMode._(0);

  /// A launcher that floats and can be dragged around the screen.
  static const LauncherMode floating = LauncherMode._(1);

  /// All available launcher modes.
  static const List<LauncherMode> values = <LauncherMode>[static, floating];

  @override
  String toString() {
    return const <int, String>{0: '1', 1: '2'}[index]!;
  }
}

/// The initial placement and appearance of the launcher, used when configuring
/// a custom launcher.
class LauncherProperties {
  /// The layout mode of the launcher.
  LauncherMode mode = LauncherMode.floating;

  /// Vertical offset (in dp) measured from the bottom of the screen.
  ///
  /// Applies only for Android; maps to the native
  /// `LauncherProperties.setYFromBottom()`.
  int? yFromBottom;

  /// The resource name of the custom **chat** launcher icon.
  String? chatIcon;

  /// The resource name of the custom **call** launcher icon.
  String? callIcon;

  /// The resource name of the custom **create** (new chat) launcher icon.
  String? createIcon;

  /// The resource name of the custom **close** launcher icon.
  String? closeIcon;

  /// The horizontal edge the launcher is anchored to.
  Horizontal? horizontalDirection;

  /// The vertical edge the launcher is anchored to.
  Vertical? verticalDirection;

  /// Creates launcher properties for the given [launcherMode].
  LauncherProperties(LauncherMode launcherMode) {
    mode = launcherMode;
  }
}

/// The horizontal edge the launcher is anchored to.
class Horizontal {
  const Horizontal._(this.index);

  /// The ordinal index of the direction.
  final int index;

  /// Anchor the launcher to the left edge.
  static const Horizontal left = Horizontal._(0);

  /// Anchor the launcher to the right edge.
  static const Horizontal right = Horizontal._(1);

  /// All available horizontal directions.
  static const List<Horizontal> values = <Horizontal>[left, right];

  @override
  String toString() {
    return const <int, String>{
      0: 'HORIZONTAL_LEFT',
      1: 'HORIZONTAL_RIGHT'
    }[index]!;
  }
}

/// The vertical edge the launcher is anchored to.
class Vertical {
  const Vertical._(this.index);

  /// The ordinal index of the direction.
  final int index;

  /// Anchor the launcher to the top edge.
  static const Vertical top = Vertical._(0);

  /// Anchor the launcher to the bottom edge.
  static const Vertical bottom = Vertical._(1);

  /// All available vertical directions.
  static const List<Vertical> values = <Vertical>[top, bottom];

  @override
  String toString() {
    return const <int, String>{0: 'VERTICAL_TOP', 1: 'VERTICAL_BOTTOM'}[index]!;
  }
}
