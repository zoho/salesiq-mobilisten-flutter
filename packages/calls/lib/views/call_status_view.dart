import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

/// A Flutter widget that displays a status bar view for active SalesIQ calls on Android devices.
///
/// This widget provides a compact status bar overlay that appears when there's an active call,
/// allowing users to see call information and tap to return to the full screen call interface.
/// The widget automatically shows/hides based on call state and only displays on Android platforms.
///
/// The status bar view includes:
/// - Visual representation of the current call status
/// - Tap gesture handling to enter full screen mode
/// - Automatic theme adaptation based on dark/light mode
/// - Real-time updates based on call state changes
///
/// Example usage:
/// ```dart
/// SalesIQAndroidCallStatusBarView(
///   isDarkMode: true/false,
/// )
/// ```
class SalesIQAndroidCallStatusBarView extends StatefulWidget {
  /// Determines whether the status bar should use dark mode styling.
  ///
  /// When set to `true`, the status bar will use dark theme colors and styling.
  /// When set to `false`, it will use light theme styling.
  /// This should typically be synchronized with your app's current theme.
  final bool isDarkMode;

  /// Creates a new instance of [SalesIQAndroidCallStatusBarView].
  ///
  /// The [isDarkMode] parameter is required and determines the visual theme
  /// of the status bar view.
  ///
  /// Parameters:
  /// - [key]: An optional key to identify this widget
  /// - [isDarkMode]: Whether to use dark mode styling for the status bar
  const SalesIQAndroidCallStatusBarView({super.key, required this.isDarkMode});

  /// Creates the mutable state for this widget.
  ///
  /// Returns a [SalesIQCallViewState] instance that manages the widget's state,
  /// including call status monitoring, view loading, and UI updates.
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
