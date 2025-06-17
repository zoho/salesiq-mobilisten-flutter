import 'package:salesiq_mobilisten/siqtheme/colorutils.dart';
import 'package:salesiq_mobilisten/siqtheme/siqchatformtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqchatwindowtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqconversationtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqemptyviewtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqfaqtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqfeedbacktheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqinappnotificationtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqlaunchertheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqnavigationtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqnonetworkbannertheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqofflinebannertheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqtabbartheme.dart';

class SIQTheme {
  // ignore_for_file: public_member_api_docs

  String? themeColor;
  SIQLauncherTheme launcher;
  SIQTabBarTheme tabBar;
  SIQNavigationTheme navigation;
  SIQEmptyViewTheme emptyView;
  SIQOfflineBannerTheme offlineBanner;
  SIQNoNetworkBannerTheme networkWaitingBanner;
  SIQConversationTheme conversation;
  SIQFAQTheme faq;
  SIQChatWindowTheme chat;
  SIQChatFormTheme form;
  SIQFeedbackTheme feedback;
  SIQInAppNotificationTheme inAppNotification;

  SIQTheme({
    this.themeColor,
    SIQLauncherTheme? launcher,
    SIQTabBarTheme? tabBar,
    SIQNavigationTheme? navigation,
    SIQEmptyViewTheme? emptyView,
    SIQOfflineBannerTheme? offlineBanner,
    SIQNoNetworkBannerTheme? networkWaitingBanner,
    SIQConversationTheme? conversation,
    SIQFAQTheme? faq,
    SIQChatWindowTheme? chat,
    SIQChatFormTheme? form,
    SIQFeedbackTheme? feedback,
    SIQInAppNotificationTheme? inAppNotification,
  })  : launcher = launcher ?? SIQLauncherTheme(),
        tabBar = tabBar ?? SIQTabBarTheme(),
        navigation = navigation ?? SIQNavigationTheme(),
        emptyView = emptyView ?? SIQEmptyViewTheme(),
        offlineBanner = offlineBanner ?? SIQOfflineBannerTheme(),
        networkWaitingBanner =
            networkWaitingBanner ?? SIQNoNetworkBannerTheme(),
        conversation = conversation ?? SIQConversationTheme(),
        faq = faq ?? SIQFAQTheme(),
        chat = chat ?? SIQChatWindowTheme(),
        form = form ?? SIQChatFormTheme(),
        feedback = feedback ?? SIQFeedbackTheme(),
        inAppNotification = inAppNotification ?? SIQInAppNotificationTheme();

  Map<String, dynamic> toMap() {
    return {
      'themeColor': colorToHex(themeColor),
      'Launcher': launcher.toMap(),
      'TabBar': tabBar.toMap(),
      'Navigation': navigation.toMap(),
      'EmptyView': emptyView.toMap(),
      'OfflineBanner': offlineBanner.toMap(),
      'NetworkWaitingBanner': networkWaitingBanner.toMap(),
      'Conversation': conversation.toMap(),
      'FAQ': faq.toMap(),
      'Chat': chat.toMap(),
      'Form': form.toMap(),
      'Feedback': feedback.toMap(),
      'InAppNotification': inAppNotification.toMap(),
    };
  }
}
