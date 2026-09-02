import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import 'routes.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'state/listeners.dart';
import 'state/push_status.dart';
import 'theme/theme.dart';
import 'tracking/page_title_observer.dart';
import 'widgets/ui/toast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MobilistenSampleApp(state: AppState()));
}

/// Root of the Mobilisten Flutter sample. Initializes the SDK automatically at
/// launch (status-only UI — no init/register buttons), wires the central event
/// listeners, and drives the light/dark/system theme override.
class MobilistenSampleApp extends StatefulWidget {
  final AppState state;
  const MobilistenSampleApp({super.key, required this.state});

  @override
  State<MobilistenSampleApp> createState() => _MobilistenSampleAppState();
}

class _MobilistenSampleAppState extends State<MobilistenSampleApp>
    with WidgetsBindingObserver {
  late final EventListeners _listeners;
  // Central page-title tracker: reports every screen the visitor lands on to
  // SalesIQ. Held as a single instance so it survives theme-driven rebuilds.
  final PageTitleObserver _pageTracker = PageTitleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listeners = EventListeners(widget.state.events);
    _initMobilisten();
    // Notification permission: request once at startup (Android 13+ runtime
    // prompt; iOS system prompt), then publish the status to the app-wide
    // push-status store that drives the global header warning bell. Independent
    // of SDK init. Mirrors the RN `App.tsx` wiring.
    pushStatus.requestAndRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-read on every foreground so the header warning clears right after the
      // user enables notifications in OS settings and returns.
      pushStatus.refresh();
    }
  }

  Future<void> _initMobilisten() async {
    final app = widget.state;

    if (!io.Platform.isIOS && !io.Platform.isAndroid) {
      app.initStatus.value = InitStatus.failed;
      return;
    }

    final bool isIOS = io.Platform.isIOS;
    // Placeholder keys ship with the sample; a real app injects real keys here.
    final appKey = isIOS ? kPlaceholderIosAppKey : kPlaceholderAndroidAppKey;
    final accessKey =
        isIOS ? kPlaceholderIosAccessKey : kPlaceholderAndroidAccessKey;
    app.appKey = appKey;
    app.accessKey = accessKey;

    // Start listening before init so early events are captured.
    _listeners.start();

    if (hasPlaceholderKeys(appKey, accessKey)) {
      app.initStatus.value = InitStatus.keysRequired;
      return;
    }

    try {
      // Bundle the app/access keys into the config object the SDK expects.
      final configuration =
          SalesIQConfiguration(appKey: appKey, accessKey: accessKey);
      // Boot the SalesIQ SDK with your credentials; must succeed before any other SDK call.
      await ZohoSalesIQ.initialize(configuration);
      // Keep the floating chat launcher button visible on every screen.
      ZohoSalesIQ.launcher.show(VisibilityMode.always);
      app.initStatus.value = InitStatus.initialized;
    } catch (e) {
      debugPrint('Mobilisten init error: $e');
      app.initStatus.value = InitStatus.failed;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _listeners.dispose();
    widget.state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.state;
    return AppScope(
      state: app,
      child: AnimatedBuilder(
        animation: app.theme,
        builder: (context, _) {
          return MaterialApp(
            title: 'Mobilisten',
            debugShowCheckedModeBanner: false,
            theme: appLightTheme,
            darkTheme: appDarkTheme,
            themeMode: app.theme.mode,
            initialRoute: Routes.home,
            routes: Routes.map,
            navigatorObservers: [_pageTracker],
            builder: (context, child) =>
                ToastHost(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}
