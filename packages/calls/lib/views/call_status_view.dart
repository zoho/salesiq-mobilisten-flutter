import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

/// A Flutter widget that shows a status bar view for active SalesIQ calls on
/// Android devices.
///
/// This widget shows a compact status bar when there is an active call.
/// Visitors can see call information, and tap the bar to return to the full
/// screen call view. The widget shows and hides automatically based on the call
/// state, and it appears only on Android.
///
/// The status bar view includes:
/// - The current call status.
/// - Tap handling that opens the full screen mode.
/// - A theme that follows dark or light mode automatically.
/// - Real-time updates when the call state changes.
///
/// Example:
/// ```dart
/// SalesIQAndroidCallStatusBarView(
///   isDarkMode: true/false,
/// )
/// ```
class SalesIQAndroidCallStatusBarView extends StatefulWidget {
  /// Determines whether the status bar uses dark mode styling.
  ///
  /// When it is `true`, the status bar uses dark theme colors and styling. When
  /// it is `false`, it uses light theme styling. Usually, you match this value
  /// to the current theme of your app.
  final bool isDarkMode;

  /// Creates a new instance of [SalesIQAndroidCallStatusBarView].
  ///
  /// The [isDarkMode] parameter is required. It sets the visual theme of the
  /// status bar view.
  ///
  /// Parameters:
  /// - [key]: An optional key that identifies this widget.
  /// - [isDarkMode]: Whether the status bar uses dark mode styling.
  const SalesIQAndroidCallStatusBarView({super.key, required this.isDarkMode});

  /// Creates the mutable state for this widget.
  ///
  /// Returns a [SalesIQCallViewState] instance that manages the state of the
  /// widget. This includes watching the call status, loading the view, and
  /// updating the UI.
  @override
  SalesIQCallViewState createState() => SalesIQCallViewState();
}

/// The state class for [SalesIQAndroidCallStatusBarView].
class SalesIQCallViewState extends State<SalesIQAndroidCallStatusBarView> {
  String? _viewType;
  Map<dynamic, dynamic>? _viewParams;
  bool _canShow = false;
  String? _error;
  late StreamSubscription<CallEvent> _callsEventSubscription;

  @override
  void initState() {
    super.initState();
    if (io.Platform.isAndroid) {
      _loadCallView();
      ZohoSalesIQCalls.currentState.then((state) {
        setState(() {
          _canShow = state?.status.isCallActive ?? false;
        });
      });
      _callsEventSubscription = ZohoSalesIQCalls.events.listen((event) {
        if (event is CallStateChanged) {
          setState(() {
            _canShow = event.state.status.isCallActive;
          });
        }
      });
    }
  }

  Future<void> _loadCallView() async {
    try {
      final result = await ZohoSalesIQCalls.getStatusBarView(widget.isDarkMode);
      if (result['success'] == true && mounted) {
        setState(() {
          _viewType = result['viewType'] as String?;
          _viewParams = Map<dynamic, dynamic>.from(result);
        });
      } else {
        _handleError('Invalid view parameters');
      }
    } catch (e) {
      _handleError('Error loading call view: $e');
    }
  }

  void _handleError(String error) {
    if (mounted) {
      setState(() {
        _canShow = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isVisible = io.Platform.isAndroid &&
        _canShow &&
        _viewType != null &&
        _error == null;
    return Visibility(
        visible: isVisible,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 28,
            minWidth: 0,
            maxWidth: double.infinity,
          ),
          child: IntrinsicHeight(
            child: isVisible
                ? Stack(
                    children: [
                      ZohoSalesIQCalls.buildStatusBarView(
                        viewType: _viewType!,
                        params: _viewParams,
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () {
                            ZohoSalesIQCalls.enterFullScreenMode();
                          },
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
        ));
  }

  @override
  void dispose() {
    _callsEventSubscription.cancel();
    super.dispose();
  }
}
