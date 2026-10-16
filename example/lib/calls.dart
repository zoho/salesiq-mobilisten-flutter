import 'dart:async';

import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';
import 'package:salesiq_mobilisten_calls/salesiq_mobilisten_calls.dart';

class CallDemoScreen extends StatefulWidget {
  @override
  State<CallDemoScreen> createState() => _CallDemoScreenState();
}

class _CallDemoScreenState extends State<CallDemoScreen> {
  SalesIQCallState? _callState;
  String? _callId;
  String? _callQueuePosition = "Not in queue";
  bool _isEnabled = false,
      _isPrechatEnabled = false,
      _isOperatorNameEnabled = false,
      _isOperatorImageEnabled = false,
      _isQueuePositionEnabled = false;
  List<SalesIQConversation> _conversations = [];
  late StreamSubscription<CallEvent> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _updateCurrentCallStats(true);
    _streamSubscription = ZohoSalesIQCalls.events.listen((event) {
      if (event is CallStateChanged) {
        _updateCurrentCallStats(false);
        _getConversations();
        setState(() {
          _callState = event.state;
        });
      } else if (event is QueuePositionChanged) {
        setState(() {
          if (event.position > 0) {
            _callQueuePosition = event.position.toString();
          } else {
            _callQueuePosition = null;
          }
        });
      }
    });
  }

  Future<void> _updateCurrentCallStats(bool isInitialUpdate) async {
    if (isInitialUpdate) {
      final isEnabled = await ZohoSalesIQCalls.isEnabled;
      final callId = await ZohoSalesIQCalls.currentCallId;
      final state = await ZohoSalesIQCalls.currentState;
      _getConversations();
      setState(() {
        _isEnabled = isEnabled;
        _callId = callId;
        _callState = state;
      });
    } else {
      final callId = await ZohoSalesIQCalls.currentCallId;
      setState(() {
        _callId = callId;
      });
    }
  }

  void _getCommunicationMode() async {
    CommunicationMode? communicationMode =
        await ZohoSalesIQ.getCommunicationMode();
    // Toast the communication mode in UI
    if (communicationMode != null) {
      debugPrint("Communication Mode: $communicationMode");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Communication Mode: $communicationMode")),
      );
    } else {
      debugPrint("No communication mode set");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No communication mode received")),
      );
    }

    // debugPrint();
  }

  void _startCall() async {
    // SalesIQConversationAttributes attributes = SalesIQConversationAttributes(
    //   name: "Support Team",
    //   additionalInfo: "Urgent issue",
    //   displayPicture:
    //       "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmcpiyts9M3zpanvqrDoltvPffjbLIborLnHG7oaZVx2c_yeLzDBqKCeBSkvJizNfntWA&usqp=CAU",
    //   departments: [
    //     SalesIQDepartment.fromName("David Bhahirathan Private",
    //         communicationMode: CommunicationMode.chatAndCall)
    //   ],
    // );
    ZohoSalesIQCalls.start(
            // attributes: attributes
            )
        .then((conversation) {
      debugPrint("Call started with ID: ${conversation?.id}");
    }).catchError((error) {
      debugPrint("Error starting call: $error");
    });
  }

  void _endCall() async {
    ZohoSalesIQCalls.end().then((result) {
      debugPrint("Call ended with action: $result");
    }).catchError((error) {
      debugPrint("Error ending call: $error");
    });
  }

  void _getConversations() async {
    final list = await ZohoSalesIQCalls.getList();
    setState(() => _conversations = list);
  }

  void _toggleComponent(CallComponent component) {
    bool visible = false;
    setState(() {
      switch (component) {
        case CallComponent.operatorName:
          visible = !_isOperatorNameEnabled;
          _isOperatorNameEnabled = visible;
          break;
        case CallComponent.operatorImage:
          visible = !_isOperatorImageEnabled;
          _isOperatorImageEnabled = visible;
          break;
        case CallComponent.queuePosition:
          visible = !_isQueuePositionEnabled;
          _isQueuePositionEnabled = visible;
          break;
        case CallComponent.preChatForm:
          visible = !_isPrechatEnabled;
          _isPrechatEnabled = visible;
          break;
        default:
          debugPrint("Unknown component: $component");
      }
    });
    ZohoSalesIQCalls.setVisibility(component, visible);
  }

  void _setReplyMessages() {
    ZohoSalesIQCalls.setAndroidReplyMessages(
        ["Hello", "Please hold", "Thank you"]);
  }

  void _getDepartments() {
    ZohoSalesIQ.conversation.getDepartments().then((departments) {
      debugPrint("Departments: ${departments.map((d) => d.name).join(', ')}");
    }).catchError((error) {
      debugPrint("Error fetching departments: $error");
    });
  }

  void _enterFullScreen() {
    ZohoSalesIQCalls.enterFullScreenMode();
  }

  void _enterFloatingViewMode() {
    ZohoSalesIQCalls.enterFloatingViewMode();
  }

  void _setTitle() {
    ZohoSalesIQCalls.setTitle("Online Call Support", "Offline Call support");
    ZohoSalesIQ.chat.setTitle("Online Chat Support", "Offline Chat support");
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ElevatedButton(
        onPressed: _getCommunicationMode,
        child: const Text('Communication mode'),
      ),
      ElevatedButton(
        onPressed: _startCall,
        child: const Text('Start Call'),
      ),
      ElevatedButton(
        onPressed: _endCall,
        child: const Text('End Call'),
      ),
      ElevatedButton(
        onPressed: _getConversations,
        child: const Text('Get Conversations'),
      ),
      ElevatedButton(
        onPressed: _enterFullScreen,
        child: const Text('Enter Fullscreen'),
      ),
      ElevatedButton(
        onPressed: _enterFloatingViewMode,
        child: const Text('Enter Floating Mode'),
      ),
      ElevatedButton(
        onPressed: _setTitle,
        child: const Text('Set Titles'),
      ),
      ElevatedButton(
        onPressed: _setReplyMessages,
        child: const Text('Set Reply Messages'),
      ),
      ElevatedButton(
        onPressed: _getDepartments,
        child: const Text('Get departments'),
      ),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
          _isOperatorNameEnabled
              ? Colors.green
              : Colors.red, // Change color based on visibility
        )),
        onPressed: () => _toggleComponent(CallComponent.operatorName),
        child: const Text('Toggle Operator Name Visibility'),
      ),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
          _isOperatorImageEnabled
              ? Colors.green
              : Colors.red, // Change color based on visibility
        )),
        onPressed: () => _toggleComponent(CallComponent.operatorImage),
        child: const Text('Toggle Operator Image Visibility'),
      ),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
          _isQueuePositionEnabled
              ? Colors.green
              : Colors.red, // Change color based on visibility
        )),
        onPressed: () => _toggleComponent(CallComponent.queuePosition),
        child: const Text('Toggle QueuePosition Visibility'),
      ),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
          _isPrechatEnabled
              ? Colors.green
              : Colors.red, // Change color based on visibility
        )),
        onPressed: () => _toggleComponent(CallComponent.preChatForm),
        child: const Text('Toggle PrechatForm Visibility'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Call SDK Demo')),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
            Container(
                child: SingleChildScrollView(
              // padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Is Enabled: $_isEnabled"),
                  SalesIQAndroidCallStatusBarView(isDarkMode: false),
                  Text("Call ID: $_callId"),
                  Text(
                      "Call Queue Position: ${_callQueuePosition ?? "Not in queue"}"),
                  Text(
                      "Call State: ${_callState?.status}, Is an incoming call: ${_callState?.isIncomingCall ?? "No ongoing call"}"),
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        shrinkWrap: true,
                        // Fit content to available space
                        physics: const NeverScrollableScrollPhysics(),
                        // Let SingleChildScrollView handle scrolling
                        crossAxisCount: 2,
                        // 3 buttons per row
                        crossAxisSpacing: 16.0,
                        // Horizontal spacing
                        mainAxisSpacing: 16.0,
                        // Vertical spacing
                        childAspectRatio: 3.0,
                        // Width:Height ratio for buttons
                        children: buttons,
                      )),
                  // ElevatedButton(
                  //     onPressed: _startCall,
                  //     child: const Text("Start Call")),
                  // ElevatedButton(
                  //     onPressed: _endCall, child: const Text("End Call")),
                  // ElevatedButton(
                  //     onPressed: _getConversations,
                  //     child: const Text("Get Conversations")),
                  // ElevatedButton(
                  //     onPressed: _enterFullScreen,
                  //     child: const Text("Enter Fullscreen")),
                  // ElevatedButton(
                  //     onPressed: _enterFloatingViewMode,
                  //     child: const Text("Enter Floating Mode")),
                  // ElevatedButton(
                  //     onPressed: _setTitle,
                  //     child: const Text("Set Titles")),
                  // ElevatedButton(
                  //     onPressed: _setReplyMessages,
                  //     child: const Text("Set Reply Messages")),
                  // ElevatedButton(
                  //   onPressed: () =>
                  //       _toggleComponent(CallComponent.preChatForm, false),
                  //   child: const Text("Show Operator Name"),
                  // ),
                  const SizedBox(height: 20),
                  const Text("Conversations List:"),
                  for (var conversation in _conversations)
                    ListTile(
                        title: Text(conversation.id ?? 'No ID'),
                        subtitle: Text(conversation.question ?? "No Question"),
                        onTap: () =>
                            _showConversationDialog(context, conversation)),
                ],
              ),
            ))
          ])),
    );
  }

  void _showConversationDialog(
      BuildContext context, SalesIQConversation conversation) {
    // Convert conversation and media to a list of key-value pairs
    final List<MapEntry<String, String>> fields = [
      MapEntry('ID', conversation.id ?? 'N/A'),
      MapEntry(
          'Custom Conversation ID', conversation.customConversationId ?? 'N/A'),
      MapEntry('Question', conversation.question ?? 'N/A'),
      MapEntry('Attender ID', conversation.attenderId ?? 'N/A'),
      MapEntry('Attender Name', conversation.attenderName ?? 'N/A'),
      MapEntry('Attender Email', conversation.attenderEmail ?? 'N/A'),
      MapEntry('Department Name', conversation.departmentName ?? 'N/A'),
      MapEntry('Feedback', conversation.feedback ?? 'N/A'),
      MapEntry('Rating', conversation.rating ?? 'N/A'),
      MapEntry('Queue Position', conversation.queuePosition.toString()),
      if (conversation.media != null) ...[
        MapEntry('Media ID', conversation.media!.id ?? 'N/A'),
        MapEntry(
            'Media End Time', conversation.media!.endTime?.toString() ?? 'N/A'),
        MapEntry('Media Initiated By',
            conversation.media!.initiatedBy?.toString() ?? 'N/A'),
        MapEntry('Media Pickup Time',
            conversation.media!.pickupTime?.toString() ?? 'N/A'),
        MapEntry('Media Connected Time',
            conversation.media!.connectedTime?.toString() ?? 'N/A'),
        MapEntry(
            'Media Status', conversation.media!.status?.toString() ?? 'N/A'),
        MapEntry(
            'Media Ended By', conversation.media!.endedBy?.toString() ?? 'N/A'),
        MapEntry('Media Type', conversation.media!.type ?? 'N/A'),
        MapEntry('Media Created Time',
            conversation.media!.createdTime?.toString() ?? 'N/A'),
      ] else
        MapEntry('Media', 'N/A'),
      if (conversation is SalesIQCallConversation)
        MapEntry('Call Status', conversation.status?.toString() ?? 'N/A')
    ];

    if (conversation is SalesIQCallConversation) {
      fields.add(MapEntry('Type', "Call"));
    } else if (conversation is SalesIQChatConversation) {
      fields.add(MapEntry('Type', "Chat"));
      if (conversation.lastSalesIQMessage != null) {
        fields.add(MapEntry('Is read',
            conversation.lastSalesIQMessage?.isRead.toString() ?? 'N/A'));
        fields.add(MapEntry(
            'Status', conversation.lastSalesIQMessage?.status?.name ?? 'N/A'));
        fields.add(MapEntry(
            'Time', conversation.lastSalesIQMessage?.time.toString() ?? 'N/A'));
        fields.add(MapEntry(
            'Sender', conversation.lastSalesIQMessage?.sender ?? 'N/A'));
        fields.add(MapEntry(
            'Sent By Visitor',
            conversation.lastSalesIQMessage?.sentByVisitor.toString() ??
                'N/A'));
        fields.add(MapEntry(
            'Sender', conversation.lastSalesIQMessage?.senderId ?? 'N/A'));
        fields.add(
            MapEntry('Text', conversation.lastSalesIQMessage?.text ?? 'N/A'));
        fields.add(MapEntry(
            'Message Type', conversation.lastSalesIQMessage?.type ?? 'N/A'));
        if (conversation.lastSalesIQMessage?.file != null) {
          fields.add(MapEntry('File Name',
              conversation.lastSalesIQMessage?.file?.name ?? 'N/A'));
          fields.add(MapEntry('File size',
              conversation.lastSalesIQMessage?.file?.size.toString() ?? 'N/A'));
          fields.add(MapEntry('File Content',
              conversation.lastSalesIQMessage?.file?.contentType ?? 'N/A'));
          fields.add(MapEntry('File comment',
              conversation.lastSalesIQMessage?.file?.comment ?? 'N/A'));
        }
      }
    } else {
      fields.add(MapEntry('Type', "undefined"));
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Conversation Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Container(
          width: double.maxFinite, // Ensure dialog uses available width
          constraints: BoxConstraints(maxHeight: 400), // Limit height
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: fields.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final field = fields[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        field.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        field.value,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
