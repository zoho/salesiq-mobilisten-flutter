import 'package:flutter/material.dart';
import 'package:salesiq_mobilisten/salesiq_mobilisten.dart';

import '../state/app_scope.dart';
import '../state/events.dart';
import '../widgets/ui/ui.dart';

enum _SourceKey { app, sdk }

/// Screen 09 — push registers automatically; status, in-app toggle, action
/// source, last payload. Mirrors the RN `NotificationsScreen`.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _inAppEnabled = true;
  _SourceKey _source = _SourceKey.app;
  int? _badgeCount;
  // In a real app this comes from FirebaseMessaging.getToken(); the sample
  // takes it as input so the register/disable APIs can be exercised.
  final _pushToken = TextEditingController();

  Object? _result;

  @override
  void initState() {
    super.initState();
    _refreshBadge();
  }

  @override
  void dispose() {
    _pushToken.dispose();
    super.dispose();
  }

  void _registerPush() {
    final token = _pushToken.text.trim();
    if (token.isEmpty) {
      showToast('Paste an FCM/APNs token first', ToastTone.danger);
      return;
    }
    // Register this device's push token so SalesIQ can send chat notifications.
    ZohoSalesIQ.notification.registerPush(token, true); // true = test device
    showToast('Push registered', ToastTone.success);
  }

  void _disablePush() {
    // Stop SalesIQ push notifications for this device. The FCM token captured
    // during registerPush is reused internally, so none needs to be passed.
    ZohoSalesIQ.notification.disablePush();
    showToast('Push disabled');
  }

  /// Re-register the push token — call this in response to the SDK's
  /// `reRegisterPush` event.
  Future<void> _reRegisterPush() async {
    await ZohoSalesIQ.notification.reRegisterPush();
    setState(() => _result = {'reRegisterPush': true});
    showToast('Re-registered push', ToastTone.success);
  }

  /// iOS notification-action handling: forward the tapped action id, the push
  /// userInfo, and any typed reply back to the SDK.
  Future<void> _handlePushAction() async {
    final userInfo = <String, dynamic>{'sender': 'salesiq', 'type': 'chat'};
    await ZohoSalesIQ.notification
        .handlePushNotificationAction('reply_action', userInfo, 'On my way!');
    setState(() => _result = {'handlePushNotificationAction': 'reply_action'});
    showToast('Handled push action', ToastTone.success);
  }

  /// The exact flow a customer runs from their FCM `onMessage` handler: check
  /// whether the payload is a SalesIQ one, hand it to the SDK, then read the
  /// parsed payload back.
  Future<void> _handleSamplePush() async {
    // Stand-in for the RemoteMessage data map delivered by FCM/APNs.
    final data = <String, dynamic>{'sender': 'salesiq', 'type': 'chat'};
    try {
      // Check whether an incoming push payload belongs to SalesIQ.
      final isSdk = await ZohoSalesIQ.notification.isSDKMessage(data);
      if (!isSdk) {
        setState(() => _result = {'isSDKMessage': false});
        showToast('Not a SalesIQ push (as expected for the sample)');
        return;
      }
      // Hand the push payload to the SDK to display/handle it.
      ZohoSalesIQ.notification.process(data);
      // Parse the raw push data into a structured SalesIQ payload object.
      final payload = await ZohoSalesIQ.notification.getPayload(data);
      setState(() => _result = {
            'isSDKMessage': true,
            'processed': true,
            'payloadType': payload?.runtimeType.toString() ?? 'none',
          });
      showToast('Push handled', ToastTone.success);
    } catch (e) {
      setState(() => _result = {'error': e.toString()});
      showToast('Push handling failed', ToastTone.danger);
    }
  }

  Future<void> _refreshBadge() async {
    try {
      // Read the current unread-notification badge count from the SDK.
      final count = await ZohoSalesIQ.notification.getBadgeCount();
      if (!mounted) return;
      setState(() => _badgeCount = count);
    } catch (_) {
      // Leave unknown; the banner is status-only.
    }
  }

  void _toggleInApp(bool value) {
    setState(() => _inAppEnabled = value);
    // Show/suppress SalesIQ notifications as in-app banners while the app is open.
    ZohoSalesIQ.notification.enableInAppNotification(value);
  }

  void _applySource(_SourceKey value) {
    setState(() => _source = value);
    // Choose who handles a notification tap: the host app or the SDK.
    ZohoSalesIQ.notification.setActionSource(
      value == _SourceKey.app ? ActionSource.app : ActionSource.sdk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ScreenScaffold(
      title: 'Notifications',
      subtitle: 'Push status & in-app alerts',
      children: [
        StatusBanner(
          title: 'Push connected',
          body: _badgeCount == null
              ? 'Registered automatically at startup and handled by the platform messaging service.'
              : 'Registered automatically at startup · $_badgeCount unread in the badge.',
          variant: BannerVariant.ok,
          icon: AppIcon.notifications,
        ),
        Section(
          title: 'Preferences',
          child: AppCard(
            children: [
              SwitchRow(
                title: 'In-app notifications',
                subtitle: 'Show alerts inside the app',
                value: _inAppEnabled,
                onChanged: _toggleInApp,
              ),
            ],
          ),
        ),
        Section(
          title: 'Action source',
          footer: 'Who handles a tap on a chat notification.',
          child: SegmentedControl<_SourceKey>(
            value: _source,
            onChanged: _applySource,
            segments: const [
              Segment(_SourceKey.app, 'App'),
              Segment(_SourceKey.sdk, 'SDK'),
            ],
          ),
        ),
        Section(
          title: 'Push token',
          footer:
              'In production the token comes from FirebaseMessaging.getToken(). '
              'Registered as a test device here.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(children: [
                Field(
                  label: 'FCM / APNs token',
                  controller: _pushToken,
                  placeholder: 'Paste a device token',
                  textCapitalization: TextCapitalization.none,
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: AppButton(
                    title: 'Register push',
                    variant: ButtonVariant.secondary,
                    onPressed: _registerPush,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    title: 'Disable push',
                    variant: ButtonVariant.secondary,
                    onPressed: _disablePush,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              AppButton(
                title: 'Handle sample push',
                variant: ButtonVariant.ghost,
                onPressed: _handleSamplePush,
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: AppButton(
                    title: 'Re-register push',
                    variant: ButtonVariant.secondary,
                    onPressed: _reRegisterPush,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    title: 'Handle push action',
                    variant: ButtonVariant.secondary,
                    onPressed: _handlePushAction,
                  ),
                ),
              ]),
              if (_result != null) ...[
                const SizedBox(height: 12),
                ResultBlock(label: 'Last result', data: _result),
              ],
            ],
          ),
        ),
        Section(
          title: 'Last payload received',
          child: ListenableBuilder(
            listenable: app.events,
            builder: (context, _) {
              final last = app.events.latestOf(EventSource.notification);
              return ResultBlock(
                data:
                    last?.payload ?? {'status': 'No notification received yet'},
              );
            },
          ),
        ),
      ],
    );
  }
}
