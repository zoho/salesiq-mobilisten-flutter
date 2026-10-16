import 'package:flutter/services.dart';

// ignore_for_file: public_member_api_docs

/// Provides the APIs to control the SalesIQ launcher view.
///
/// It matches the native `ZohoSalesIQ.Launcher` namespace on Android and iOS.
/// To use it, call [ZohoSalesIQ.launcher].
class Launcher {
  final MethodChannel _channel = const MethodChannel("salesiq_launcher_module");

  /// The broadcast stream of launcher events from the `ZohoSalesIQ.Launcher`
  /// namespace.
  ///
  /// For now, it sends only the change in visibility of the custom launcher. For
  /// backward compatibility, [ZohoSalesIQ.eventChannel] still sends the general
  /// [SIQEvent.customLauncherVisibility] event too.
  final Stream<LauncherEvent> eventChannel =
      EventChannel("mobilistenLauncherEventChannel")
          .receiveBroadcastStream()
          .map((event) =>
              CustomLauncherVisibilityEvent(event["visible"] as bool? ?? false));

  /// Controls the visibility of the default launcher with the given [mode].
  void show(VisibilityMode mode) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("visibility_mode", () => mode.index);
    _channel.invokeMethod('show', arguments);
  }

  /// Sets the visibility [mode] of a custom launcher view.
  ///
  /// A custom launcher uses [VisibilityMode.never] by default, so it stays
  /// hidden until you set a visibility mode with this method.
  void setVisibilityModeToCustomLauncher(VisibilityMode mode) {
    Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent("visibility_mode", () => mode.index);
    _channel.invokeMethod('setVisibilityModeToCustomLauncher', arguments);
  }

  /// Turns drag to dismiss on or off for the launcher, based on the value of
  /// [enable].
  void enableDragToDismiss(bool enable) {
    _channel.invokeMethod('enableDragToDismiss', enable);
  }

  /// Sets [value], the minimum press duration in milliseconds that the visitor
  /// needs to start dragging the launcher.
  void setMinimumPressDuration(int value) {
    _channel.invokeMethod('setMinimumPressDuration', value);
  }

  /// Shows or hides the operator's image on the launcher during an active chat,
  /// based on the value of [show].
  void showOperatorImage(bool show) {
    _channel.invokeMethod('showOperatorImage', show);
  }

  /// Refreshes the launcher and brings the launcher view to the front.
  void refreshLauncher() {
    _channel.invokeMethod('refresh');
  }
}

/// The base type for the events that [Launcher.eventChannel] sends.
///
/// Each event carries only its own data, so you can never read a field such as
/// [CustomLauncherVisibilityEvent.visible] on an unrelated event. Each kind of
/// event is its own subclass, so check the type of an event with `is` before
/// you read its fields.
abstract class LauncherEvent {}

/// Sent when the visibility of the custom launcher changes.
class CustomLauncherVisibilityEvent extends LauncherEvent {
  /// Whether the custom launcher should now be visible.
  final bool visible;

  /// Creates a custom launcher visibility event with the given [visible] state.
  CustomLauncherVisibilityEvent(this.visible);
}

/// Defines when the launcher is visible.
enum VisibilityMode {
  /// The launcher is always visible.
  always,

  /// The launcher is never visible.
  never,

  /// The launcher is visible only during an active chat.
  whenActiveChat
}

/// Defines the layout mode of the launcher view.
class LauncherMode {
  const LauncherMode._(this.index);

  /// The ordinal index of the mode.
  final int index;

  /// A launcher that stays at a fixed position.
  static const LauncherMode static = LauncherMode._(0);

  /// A floating launcher that the visitor can drag around the screen.
  static const LauncherMode floating = LauncherMode._(1);

  /// All available launcher modes.
  static const List<LauncherMode> values = <LauncherMode>[static, floating];

  @override
  String toString() {
    return const <int, String>{0: '1', 1: '2'}[index]!;
  }
}

/// The initial position and appearance of the launcher, for when you configure
/// a custom launcher.
class LauncherProperties {
  /// The layout mode of the launcher.
  LauncherMode mode = LauncherMode.floating;

  /// The vertical offset, in pixels, from the bottom of the screen.
  ///
  /// This works only on Android. It matches the native
  /// `LauncherProperties.setYFromBottom()`.
  int? yFromBottom;

  /// The resource name of the custom **chat** launcher icon.
  String? chatIcon;

  /// The resource name of the custom **call** launcher icon.
  String? callIcon;

  /// The resource name of the custom **create** launcher icon, which starts a
  /// new chat.
  String? createIcon;

  /// The resource name of the custom **close** launcher icon.
  String? closeIcon;

  /// The horizontal edge that the launcher is anchored to.
  Horizontal? horizontalDirection;

  /// The vertical edge that the launcher is anchored to.
  Vertical? verticalDirection;

  /// Creates launcher properties for the given [launcherMode].
  LauncherProperties(LauncherMode launcherMode) {
    mode = launcherMode;
  }
}

/// The horizontal edge that the launcher is anchored to.
class Horizontal {
  const Horizontal._(this.index);

  /// The ordinal index of the direction.
  final int index;

  /// Anchors the launcher to the left edge.
  static const Horizontal left = Horizontal._(0);

  /// Anchors the launcher to the right edge.
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

/// The vertical edge that the launcher is anchored to.
class Vertical {
  const Vertical._(this.index);

  /// The ordinal index of the direction.
  final int index;

  /// Anchors the launcher to the top edge.
  static const Vertical top = Vertical._(0);

  /// Anchors the launcher to the bottom edge.
  static const Vertical bottom = Vertical._(1);

  /// All available vertical directions.
  static const List<Vertical> values = <Vertical>[top, bottom];

  @override
  String toString() {
    return const <int, String>{0: 'VERTICAL_TOP', 1: 'VERTICAL_BOTTOM'}[index]!;
  }
}
