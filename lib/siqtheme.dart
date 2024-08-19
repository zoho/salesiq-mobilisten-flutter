import 'package:salesiq_mobilisten/SIQTheme/SIQLauncherTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQTabBarTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQNavigationTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQEmptyViewTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQOfflineBannerTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQNoNetworkBannerTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQConversationTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQFAQTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQChatWindowTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQChatFormTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQFeedbackTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQInAppNotificationTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/ColorUtils.dart';

class SIQTheme {
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
