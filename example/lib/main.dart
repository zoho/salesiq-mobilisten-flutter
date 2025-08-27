import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/material.dart';
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

      SalesIQConfiguration configuration =
          SalesIQConfiguration(appKey: appKey, accessKey: accessKey)
              // .copyWith(callViewMode: SalesIQCallViewMode.floating);
              .copyWith(callViewMode: SalesIQCallViewMode.banner);

      ZohoSalesIQ.initialize(configuration).then((_) {
        // initialization successful
        ZohoSalesIQ.launcher.show(VisibilityMode.always);
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
      home: MobilistenDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MobilistenDemoScreen extends StatelessWidget {
  final TextEditingController _visitorIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      padding: EdgeInsets.symmetric(vertical: 16),
      textStyle: TextStyle(fontSize: 16),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Mobilisten Demo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/images/mobilisten_sdk.png',
                  height: 120), // Replace with your image
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                ZohoSalesIQ.present();
              },
              style: buttonStyle,
              child: Center(child: Text("Open SalesIQ support")),
            ),

            SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Custom launchers:", style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    FloatingActionButton.extended(
                      heroTag: "chat",
                      backgroundColor: Colors.blue,
                      // child: Icon(Icons.message_rounded),
                      onPressed: () {
                        ZohoSalesIQ.chat.start("Hello");
                      },
                      label: Icon(Icons.message_rounded),
                    ),
                    SizedBox(width: 12),
                  ],
                )
              ],
            ),

            SizedBox(height: 16),
            ToggleRow(
                label: "Launcher visibility :",
                option1: "Show",
                option2: "Hide",
                onOptionSelected: (String option) {
                  if (option == "Show") {
                    ZohoSalesIQ.launcher.show(VisibilityMode.always);
                  } else {
                    ZohoSalesIQ.launcher.show(VisibilityMode.never);
                  }
                }),
            SizedBox(height: 16),
            ToggleRow(
                label: "Launcher position :",
                option1: "Floating",
                option2: "Static",
                onOptionSelected: (String option) {
                  LauncherProperties launcherProperties;
                  if (option == "Floating") {
                    launcherProperties =
                        LauncherProperties(LauncherMode.floating);
                  } else {
                    launcherProperties =
                        LauncherProperties(LauncherMode.static);
                  }
                  ZohoSalesIQ.setLauncherPropertiesForAndroid(
                      launcherProperties);
                }),
            Divider(height: 32),

            TextField(
              maxLength: 100,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter visitor's unique ID",
              ),
              controller: _visitorIdController,
            ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ZohoSalesIQ.registerVisitor(_visitorIdController.text)
                          .then((value) => {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Visitor registered"),
                                  ),
                                )
                              })
                          .catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error registering visitor " + error),
                          ),
                        );
                      });
                    },
                    style: buttonStyle,
                    child: Text("Login"),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ZohoSalesIQ.unregisterVisitor();
                    },
                    style: buttonStyle,
                    child: Text("Logout"),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {},
              style: buttonStyle,
              child: Center(child: Text("Set visitor details")),
            ),

            SizedBox(height: 24),
            Text("Support language :", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Row(
              children: [
                _langButton("en"),
                _langDivider(),
                _langButton("fr"),
                _langDivider(),
                _langButton("ar"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _langButton(String lang) {
    return TextButton(
        onPressed: () {
          ZohoSalesIQ.setLanguage(lang);
        },
        child: Text(lang.toUpperCase(), style: TextStyle(color: Colors.blue)));
  }

  Widget _langDivider() {
    return Text("|", style: TextStyle(color: Colors.grey));
  }
}

class ToggleRow extends StatefulWidget {
  final String label;
  final String option1;
  final String option2;
  final Function(String) onOptionSelected;

  const ToggleRow({
    required this.label,
    required this.option1,
    required this.option2,
    required this.onOptionSelected,
    Key? key,
  }) : super(key: key);

  @override
  _ToggleRowState createState() => _ToggleRowState(onOptionSelected);
}

class _ToggleRowState extends State<ToggleRow> {
  bool isFirstSelected = true;
  final Function(String) onOptionSelected;

  _ToggleRowState(this.onOptionSelected);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 16)),
        Container(
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFirstSelected = true;
                    onOptionSelected.call(widget.option1);
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isFirstSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.option1,
                    style: TextStyle(
                      color: isFirstSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFirstSelected = false;
                    onOptionSelected.call(widget.option2);
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: !isFirstSelected ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.option2,
                    style: TextStyle(
                      color: !isFirstSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
