import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter + SPM Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _isInitialized = false;
  String _initStatus = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initializeMobilisten();
  }

  Future<void> _initializeMobilisten() async {
    try {
      if (io.Platform.isIOS || io.Platform.isAndroid) {
        // Configure SalesIQ with app key and access key
        const String appKey = "APP_KEY";
        const String accessKey = "ACCESS_KEY";

        final configuration = SalesIQConfiguration(
          appKey: appKey,
          accessKey: accessKey,
        );

        // Initialize ZohoSalesIQ with configuration
        await ZohoSalesIQ.initialize(configuration).then((_) {
          // Show launcher after successful initialization
          ZohoSalesIQ.launcher.show(VisibilityMode.always);
          setState(() {
            _isInitialized = true;
            _initStatus = "Mobilisten Initialized";
          });
          debugPrint("ZohoSalesIQ initialized successfully");
        }).catchError((error) {
          setState(() {
            _initStatus = "Initialization failed: $error";
          });
          debugPrint("ZohoSalesIQ initialization error: $error");
        });

        // Initialize ZohoSalesIQCalls
        await _initializeCalls();

        // Set iOS theme color if on iOS
        if (io.Platform.isIOS) {
          ZohoSalesIQ.setThemeColorForiOS("#6d85fc");
        }
      }
    } catch (e) {
      setState(() {
        _initStatus = "Error: $e";
      });
      debugPrint("Error during initialization: $e");
    }
  }

  Future<void> _initializeCalls() async {
    try {
      // Check if calls are enabled
      final isCallsEnabled = await ZohoSalesIQCalls.isEnabled;
      debugPrint("Calls enabled: $isCallsEnabled");

      // Listen to call events
      ZohoSalesIQCalls.events.listen((event) {
        if (event is CallStateChanged) {
          debugPrint("Call state changed: ${event.state}");
        } else if (event is QueuePositionChanged) {
          debugPrint("Queue position changed: ${event.position}");
        }
      });
    } catch (e) {
      debugPrint("Error initializing calls: $e");
    }
  }

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _initStatus,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
