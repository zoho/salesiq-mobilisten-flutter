import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
    initMobilisten();
  }

  Future<void> initMobilisten() async {
    if (io.Platform.isIOS || io.Platform.isAndroid) {
      String appKey;
      String accessKey;
      if (io.Platform.isIOS) {
        appKey = "INSERT_IOS_APP_KEY";
        accessKey = "INSERT_IOS_ACCESS_KEY";
      } else {
        appKey = "INSERT_ANDROID_APP_KEY";
        accessKey = "INSERT_ANDROID_ACCESS_KEY";
      }
      ZohoSalesIQ.init(appKey, accessKey).then((_) {
        // initialization successful
        ZohoSalesIQ.showLauncher(true);
      }).catchError((error) {
        // initialization failed
        print(error);
      });
      ZohoSalesIQ.setThemeColorForiOS("#6d85fc");
    }
  }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Example Application'),
          ),
          body: Center(child: Column(children: <Widget>[]))),
    );
  }
}
