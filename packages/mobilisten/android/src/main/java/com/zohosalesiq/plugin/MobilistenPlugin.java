package com.zohosalesiq.plugin;

import static com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin.getMap;
import static com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin.getMapList;
import static com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin.getString;
import static com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin.getStringOrNull;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.zoho.commons.ChatComponent;
import com.zoho.commons.Fonts;
import com.zoho.commons.InitConfig;
import com.zoho.commons.LauncherModes;
import com.zoho.commons.LauncherProperties;
import com.zoho.livechat.android.MobilistenActivityLifecycleCallbacks;
import com.zoho.livechat.android.NotificationListener;
import com.zoho.livechat.android.SIQDepartment;
import com.zoho.livechat.android.SIQVisitor;
import com.zoho.livechat.android.SIQVisitorLocation;
import com.zoho.livechat.android.SalesIQCustomAction;
import com.zoho.livechat.android.VisitorChat;
import com.zoho.livechat.android.config.DeviceConfig;
import com.zoho.livechat.android.constants.ConversationType;
import com.zoho.livechat.android.constants.SalesIQConstants;
import com.zoho.livechat.android.exception.InvalidEmailException;
import com.zoho.livechat.android.exception.InvalidVisitorIDException;
import com.zoho.livechat.android.listeners.ConversationListener;
import com.zoho.livechat.android.listeners.DepartmentListener;
import com.zoho.livechat.android.listeners.InitListener;
import com.zoho.livechat.android.listeners.OperatorImageListener;
import com.zoho.livechat.android.listeners.RegisterListener;
import com.zoho.livechat.android.listeners.SalesIQActionListener;
import com.zoho.livechat.android.listeners.SalesIQChatListener;
import com.zoho.livechat.android.listeners.SalesIQCustomActionListener;
import com.zoho.livechat.android.listeners.SalesIQListener;
import com.zoho.livechat.android.listeners.UnRegisterListener;
import com.zoho.livechat.android.modules.authentication.domain.entities.SalesIQAuth;
import com.zoho.livechat.android.modules.common.DataModule;
import com.zoho.livechat.android.modules.common.data.local.MobilistenEncryptedSharedPreferences;
import com.zoho.livechat.android.modules.common.domain.entities.DebugInfoData;
import com.zoho.livechat.android.modules.common.ui.LauncherUtil;
import com.zoho.livechat.android.modules.common.ui.LoggerUtil;
import com.zoho.livechat.android.modules.common.ui.entities.PresentOptions;
import com.zoho.livechat.android.modules.common.ui.lifecycle.SalesIQActivitiesManager;
import com.zoho.livechat.android.modules.common.ui.result.callbacks.ZohoSalesIQResultCallback;
import com.zoho.livechat.android.modules.common.ui.result.entities.ChatError;
import com.zoho.livechat.android.modules.common.ui.result.entities.KnowledgeBaseError;
import com.zoho.livechat.android.modules.common.ui.result.entities.SalesIQError;
import com.zoho.livechat.android.modules.common.ui.result.entities.SalesIQResult;
import com.zoho.livechat.android.modules.commonpreferences.data.local.CommonPreferencesLocalDataSource;
import com.zoho.livechat.android.modules.conversations.models.CommunicationMode;
import com.zoho.livechat.android.modules.conversations.models.SalesIQConversation;
import com.zoho.livechat.android.modules.conversations.providers.DataProviderCallback;
import com.zoho.livechat.android.modules.conversations.providers.SalesIQConversationDataProvider;
import com.zoho.livechat.android.modules.deeplinking.models.SalesIQUriScheme;
import com.zoho.livechat.android.modules.knowledgebase.ui.entities.Resource;
import com.zoho.livechat.android.modules.knowledgebase.ui.entities.ResourceCategory;
import com.zoho.livechat.android.modules.knowledgebase.ui.entities.ResourceDepartment;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.OpenResourceListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourceCategoryListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourceDepartmentsListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourceListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourcesListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.SalesIQKnowledgeBaseListener;
import com.zoho.livechat.android.modules.notifications.sdk.entities.SalesIQNotificationPayload;
import com.zoho.livechat.android.modules.visitor.models.SalesIQVisitorProfile;
import com.zoho.livechat.android.utils.LiveChatUtil;
import com.zoho.salesiq.core.config.SalesIQConfig;
import com.zoho.salesiq.core.modules.conversations.models.SalesIQConversationAttributes;
import com.zoho.salesiq.core.models.SalesIQData;
import com.zoho.salesiq.core.models.SalesIQTimeoutType;
import com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin;
import com.zoho.salesiqembed.ZohoSalesIQ;
import com.zoho.salesiqembed.models.SalesIQConfiguration;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MobilistenPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private MethodChannel channel, chatChannel, knowledgeBaseChannel, launcherChannel, notificationChannel, visitorChannel, homepageChannel, trackingChannel, chatActionsChannel, helpCenterChannel;
    private static MethodChannel conversationsChannel;
    static Application application;
    private Activity activity;

    private static String fcmtoken = null;
    private static Boolean istestdevice = true;

    static EventChannel.EventSink eventSink, chatEventSink, notificationEventSink;
    static EventChannel.EventSink knowledgeBaseEventSink;
    static EventChannel.EventSink launcherEventSink;
    private static final String MOBILISTEN_EVENT_CHANNEL = "mobilistenEventChannel";         // No I18N
    private static final String MOBILISTEN_LAUNCHER_EVENT_CHANNEL = "mobilistenLauncherEventChannel";         // No I18N
    private static final String MOBILISTEN_CHAT_EVENT_CHANNEL = "mobilistenChatEventChannel";         // No I18N
    private static final String MOBILISTEN_NOTIFICATION_EVENT_CHANNEL = "mobilistenNotificationEvents";         // No I18N

    private static final String MOBILISTEN_KNOWLEDGE_BASE_EVENTS = "mobilisten_knowledge_base_events";         // No I18N

    private static final String TYPE_OPEN = "open";         // No I18N
    private static final String TYPE_CONNECTED = "connected";         // No I18N
    private static final String TYPE_CLOSED = "closed";         // No I18N
    private static final String TYPE_ENDED = "ended";         // No I18N
    private static final String TYPE_MISSED = "missed";         // No I18N
    private static final String TYPE_WAITING = "waiting";         // No I18N

    private static final String SENDING = "sending";         // No I18N
    private static final String SENT = "sent";         // No I18N
    private static final String UPLOADING = "uploading";         // No I18N
    private static final String FAILURE = "failure";         // No I18N

    private static final String INVALID_FILTER_CODE = "604";         // No I18N
    private static final String INVALID_FILTER_TYPE = "invalid filter type";         // No I18N

    private static final String INVALID_PARAM_TYPE_CODE = "-100";         // No I18N
    private static final String INVALID_PARAM_TYPE = "Invalid param type";         // No I18N

    // Shared fallback error codes. These are the wrapper's OWN synthetic codes (not native
    // SalesIQ codes, which are positive, e.g. 604/721) — they are negative so a wrapper-origin
    // fallback is unmistakable and can't collide with a native code. Keep in sync with the iOS
    // plugin (SwiftMobilistenPlugin) so a given failure reports the same code on both platforms.
    private static final String UNKNOWN_ERROR_MESSAGE = "Unknown error";         // No I18N
    private static final String CHAT_OPERATION_FAILED_CODE = "-1001";         // No I18N
    private static final String CONVERSATION_OPERATION_FAILED_CODE = "-1002";         // No I18N
    private static final String FETCH_ATTENDER_IMAGE_FAILED_CODE = "-1003";         // No I18N
    private static final String HELP_CENTER_ASK_FAILED_CODE = "-1004";         // No I18N
    private static final String INVALID_RESOURCE_TYPE_CODE = "-1005";         // No I18N
    private static final String UNKNOWN_SCREEN_TYPE_CODE = "-1006";         // No I18N

    private static Font customFont = null;

    static final Hashtable<String, SalesIQCustomActionListener> ACTIONS_LIST = new Hashtable<>();

    Handler handler = MobilistenCorePlugin.getHandler();

    private static class Font {
        public String regular;
        public String medium;
    }

    private static class ReturnEvent {
        static final String EVENT_OPEN_URL = "OPEN_URL";  // No I18N
        static final String EVENT_COMPLETE_CHAT_ACTION = "COMPLETE_CHAT_ACTION";// No I18N
        static final String EVENT_VISITOR_REGISTRATION_FAILURE = "VISITOR_REGISTRATION_FAILURE";// No I18N
    }

    private static class Launcher {
        static final String HORIZONTAL_LEFT = "HORIZONTAL_LEFT";    // No I18N
        static final String HORIZONTAL_RIGHT = "HORIZONTAL_RIGHT";  // No I18N
        static final String VERTICAL_TOP = "VERTICAL_TOP";  // No I18N
        static final String VERTICAL_BOTTOM = "VERTICAL_BOTTOM";    // No I18N

        private static ZohoSalesIQ.Launcher.VisibilityMode getVisibilityMode(int mode) {
            ZohoSalesIQ.Launcher.VisibilityMode visibilityMode = ZohoSalesIQ.Launcher.VisibilityMode.NEVER;
            if (mode == 0) {
                visibilityMode = ZohoSalesIQ.Launcher.VisibilityMode.ALWAYS;
            } else if (mode == 2) {
                visibilityMode = ZohoSalesIQ.Launcher.VisibilityMode.WHEN_ACTIVE_CHAT;
            }
            return visibilityMode;
        }

        static void handleMethodCalls(MethodCall call, Result result) {
            switch (call.method) {
                case "show": {
                    ZohoSalesIQ.Launcher.show(getVisibilityMode(LiveChatUtil.getInteger(call.argument("visibility_mode"))));    // No I18N
                    break;
                }

                case "setVisibilityModeToCustomLauncher": {
                    ZohoSalesIQ.Launcher.setVisibilityModeToCustomLauncher(getVisibilityMode(LiveChatUtil.getInteger(call.argument("visibility_mode"))));   // No I18N
                    break;
                }

                case "enableDragToDismiss": {
                    ZohoSalesIQ.Launcher.enableDragToDismiss(LiveChatUtil.getBoolean(call.arguments));
                    break;
                }

                case "setMinimumPressDuration": {
                    ZohoSalesIQ.Launcher.setMinimumPressDuration(LiveChatUtil.getInteger(call.arguments));
                    break;
                }

                case "refresh": {
                    LauncherUtil.refreshLauncher();
                    break;
                }

                case "showOperatorImage": {
                    ZohoSalesIQ.Chat.showOperatorImageInLauncher(LiveChatUtil.getBoolean(call.arguments));
                    break;
                }
            }
        }
    }

    private final MethodCallHandler knowledgeBaseMethodCallHandler = (call, result) -> handleKnowledgeBaseMethodCalls(call, result);
    // Members promoted from the flat `ZohoSalesIQ` surface stay implemented in the
    // main `onMethodCall` handler (some hold state, e.g. shouldOpenUrl). The module
    // channels forward those calls to it so the Dart module classes can use their
    // own channels instead of reaching into the main plugin channel.
    private final MethodCallHandler conversationsMethodCallHandler = (call, result) -> handleConversationsMethodCalls(call, result);
    // Visitor: updateVisitorProfile is module-only and is served by a dedicated handler;
    // performCustomAction is also promoted to the flat `ZohoSalesIQ` facade (implemented in
    // onMethodCall), so it is forwarded there (cf. isChatMainChannelMethod).
    private final MethodCallHandler visitorMethodCallHandler = (call, result) -> {
        if (isVisitorMainChannelMethod(call.method)) {
            onMethodCall(call, result);
        } else {
            handleVisitorMethodCalls(call, result);
        }
    };
    // Homepage: all its methods are module-only, so a dedicated handler serves them.
    private final MethodCallHandler homepageMethodCallHandler = (call, result) -> handleHomepageMethodCalls(call, result);
    // Tracking: setCustomAction is module-only and is served by a dedicated handler;
    // setPageTitle is also promoted to the flat `ZohoSalesIQ` facade (implemented in
    // onMethodCall), so it is forwarded there (cf. isChatMainChannelMethod).
    private final MethodCallHandler trackingMethodCallHandler = (call, result) -> {
        if (isTrackingMainChannelMethod(call.method)) {
            onMethodCall(call, result);
        } else {
            handleTrackingMethodCalls(call, result);
        }
    };
    // ChatActions: every method reaching this channel (registerChatAction, unregisterChatAction,
    // unregisterAllChatActions, setChatActionTimeout) is also promoted to the flat `ZohoSalesIQ`
    // facade and implemented in onMethodCall, so they are all forwarded there. There are no
    // module-only ChatActions methods, hence no dedicated handler.
    private final MethodCallHandler chatActionsMethodCallHandler = (call, result) -> onMethodCall(call, result);
    // HelpCenter: helpCenterAsk is module-only, so a dedicated handler serves it.
    private final MethodCallHandler helpCenterMethodCallHandler = (call, result) -> handleHelpCenterMethodCalls(call, result);
    private final MethodCallHandler chatMethodCallHandler = (call, result) -> {
        if (isChatMainChannelMethod(call.method)) {
            onMethodCall(call, result);
        } else {
            handleChatMethodCalls(call, result);
        }
    };
    private final MethodCallHandler launcherMethodCallHandler = (call, result) -> Launcher.handleMethodCalls(call, result);
    private final MethodCallHandler notificationMethodCallHandler = (call, result) -> {
        if (isNotificationMainChannelMethod(call.method)) {
            onMethodCall(call, result);
        } else {
            Notification.handleMethodCalls(call, result);
        }
    };

    private static boolean isNotificationMainChannelMethod(String method) {
        switch (method) {
            case "enableInAppNotification":         // No I18N
            case "reRegisterPush":         // No I18N
            case "handlePushNotificationAction":         // No I18N
                return true;
            default:
                return false;
        }
    }

    // setPageTitle is promoted to the flat `ZohoSalesIQ` facade, so it stays in onMethodCall
    // and the Tracking module channel forwards it there.
    private static boolean isTrackingMainChannelMethod(String method) {
        return "setPageTitle".equals(method);         // No I18N
    }

    // performCustomAction is promoted to the flat `ZohoSalesIQ` facade, so it stays in
    // onMethodCall and the Visitor module channel forwards it there.
    private static boolean isVisitorMainChannelMethod(String method) {
        return "performCustomAction".equals(method);         // No I18N
    }

    // Members promoted from the flat `ZohoSalesIQ` surface that the Chat module
    // channel forwards to the main onMethodCall handler. Keep in sync with the
    // methods the Dart `Chat` class still routes through its own channel.
    private static final Set<String> CHAT_MAIN_CHANNEL_METHODS =
            new HashSet<>(Arrays.asList(
                    "setOperatorEmail",         // No I18N
                    "showOfflineMessage",         // No I18N
                    "end",         // No I18N
                    "fetchAttenderImage",         // No I18N
                    "isMultipleOpenChatRestricted",         // No I18N
                    "shouldOpenUrl",         // No I18N
                    "setQuestion"         // No I18N
            ));

    private static boolean isChatMainChannelMethod(String method) {
        return CHAT_MAIN_CHANNEL_METHODS.contains(method);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_mobilisten");         // No I18N
        channel.setMethodCallHandler(this);

        knowledgeBaseChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_knowledge_base");         // No I18N
        knowledgeBaseChannel.setMethodCallHandler(knowledgeBaseMethodCallHandler);

        chatChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_chat_module");  // No I18N
        chatChannel.setMethodCallHandler(chatMethodCallHandler);

        conversationsChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_conversations_module");  // No I18N
        conversationsChannel.setMethodCallHandler(conversationsMethodCallHandler);

        visitorChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_visitor_module");  // No I18N
        visitorChannel.setMethodCallHandler(visitorMethodCallHandler);

        homepageChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_homepage_module");  // No I18N
        homepageChannel.setMethodCallHandler(homepageMethodCallHandler);

        trackingChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_tracking_module");  // No I18N
        trackingChannel.setMethodCallHandler(trackingMethodCallHandler);

        chatActionsChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_chatactions_module");  // No I18N
        chatActionsChannel.setMethodCallHandler(chatActionsMethodCallHandler);

        helpCenterChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_help_center");  // No I18N
        helpCenterChannel.setMethodCallHandler(helpCenterMethodCallHandler);

        launcherChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_launcher_module");  // No I18N
        launcherChannel.setMethodCallHandler(launcherMethodCallHandler);

        notificationChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiqNotificationModule");  // No I18N
        notificationChannel.setMethodCallHandler(notificationMethodCallHandler);

        EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_EVENT_CHANNEL);
        EventChannel launcherEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_LAUNCHER_EVENT_CHANNEL);
        EventChannel chatEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_CHAT_EVENT_CHANNEL);
        EventChannel notificationEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_NOTIFICATION_EVENT_CHANNEL);
        new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_KNOWLEDGE_BASE_EVENTS).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                knowledgeBaseEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                knowledgeBaseEventSink = null;
            }
        });

        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });

        launcherEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                launcherEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                launcherEventSink = null;
            }
        });

        chatEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                chatEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                chatEventSink = null;
            }
        });

        notificationEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                notificationEventSink = events;
                Notification.sendPendingEvents();
            }

            @Override
            public void onCancel(Object arguments) {
                notificationEventSink = null;
            }
        });
    }

    private static boolean isCallbacksRegistered = false;

    public static void registerCallbacks(Application application) {
        if (!isCallbacksRegistered && application != null) {
            MobilistenActivityLifecycleCallbacks.register(application);
            SalesIQListeners salesIQListeners = new SalesIQListeners();
            ZohoSalesIQ.setListener(salesIQListeners);
            ZohoSalesIQ.Chat.setListener(salesIQListeners);
            ZohoSalesIQ.KnowledgeBase.setListener(salesIQListeners);
            ZohoSalesIQ.ChatActions.setListener(salesIQListeners);
            ZohoSalesIQ.Notification.setListener(salesIQListeners);
            isCallbacksRegistered = true;
        }
    }

    static class Notification {

        private static ArrayList<Object> pendingEventObjects = null;

        static void sendNotificationEvent(Object object) {
            if (notificationEventSink != null) {
                notificationEventSink.success(object);
            } else {
                pendingEventObjects = new ArrayList<>();
                pendingEventObjects.add(object);
            }
        }

        static void sendPendingEvents() {
            try {
                if (notificationEventSink != null && pendingEventObjects != null) {
                    for (Object object : pendingEventObjects) {
                        notificationEventSink.success(object);
                    }
                    pendingEventObjects = null;
                }
            } catch (Exception e) {
                LiveChatUtil.log(e);
            }
        }

        @Nullable
        static Map getPayloadMap(SalesIQNotificationPayload payload) {
            Map<String, Object> resultMap = new HashMap<>();
            resultMap.put("payload", getMap(payload));   // No I18N
            if (payload instanceof SalesIQNotificationPayload.Chat) {
                resultMap.put("type", "chat");    // No I18N
            } else if (payload instanceof SalesIQNotificationPayload.VisitorHistory) {
                resultMap.put("type", "visitorHistory"); // No I18N
            } else if (payload instanceof SalesIQNotificationPayload.EndChatDetails) {
                resultMap.put("type", "endChatDetails");  // No I18N
            } else {
                resultMap = null;
            }
            return resultMap;
        }

        static void handleMethodCalls(MethodCall call, Result result) {
            switch (call.method) {
                case "registerPush":
                    ZohoSalesIQ.Notification.enablePush(LiveChatUtil.getString(call.argument("token")), LiveChatUtil.getBoolean(call.argument("isTestDevice")));   // No I18N
                    break;

                case "disablePush":
                    ZohoSalesIQ.Notification.disablePush();
                    result.success(null);
                    break;

                case "getBadgeCount":
                    result.success(ZohoSalesIQ.Notification.getBadgeCount());
                    break;

                case "isSDKMessage":
                    boolean value;
                    try {
                        value = ZohoSalesIQ.Notification.isZohoSalesIQNotification((Map) call.arguments);
                    } catch (Exception e) {
                        value = false;
                    }
                    result.success(value);
                    break;

                case "process":
                    ZohoSalesIQ.Notification.handle(application, (Map) call.arguments);
                    break;

                case "setNotificationActionSource":
                    ZohoSalesIQ.Notification.setActionSource(getActionSource(LiveChatUtil.getString(call.arguments)));
                    break;

                case "getNotificationPayload":
                    Map<String, String> map = MobilistenCorePlugin.getMapOrNull(call.arguments);
                    if (map == null) {
                        result.error(INVALID_PARAM_TYPE_CODE, INVALID_PARAM_TYPE, null);
                        return;
                    }
                    ZohoSalesIQ.Notification.getPayload(map, salesIQResult -> {
                        if (salesIQResult.isSuccess()) {
                            result.success(getPayloadMap(salesIQResult.getData()));
                        } else {
                            SalesIQError salesIQError = salesIQResult.getError();
                            if (salesIQError != null) {
                                result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                            } else {
                                result.error(CHAT_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null); // No I18N
                            }
                        }
                    });
                    break;
            }
        }
    }

    static ZohoSalesIQ.ActionSource getActionSource(String source) {
        ZohoSalesIQ.ActionSource actionSource = ZohoSalesIQ.ActionSource.SDK;
        if ("app".equals(source)) {
            actionSource = ZohoSalesIQ.ActionSource.APP;
        }
        return actionSource;
    }

    static class SalesIQProviders implements SalesIQConversationDataProvider {

        private static MethodChannel providerChannel;
        private static SalesIQProviders providerInstance;

        static void register(@Nullable MethodChannel channel) {
            providerChannel = channel;
            if (providerChannel == null) {
                return;
            }
            if (providerInstance == null) {
                providerInstance = new SalesIQProviders();
            }
            ZohoSalesIQ.Conversation.setDataProvider(providerInstance);
        }

        static void unregister() {
            ZohoSalesIQ.Conversation.setDataProvider(null);
            providerChannel = null;
            providerInstance = null;
        }

        @Override
        public void getSecretFields(@NonNull SalesIQConversation conversation, @NonNull DataProviderCallback<Map<String, String>> callback) {
            invokeProviderMethod("onSecretFieldsRequested", conversation, callback); // No I18N
        }

        @Override
        public void getDisplayFields(@NonNull SalesIQConversation conversation, @NonNull DataProviderCallback<Map<String, String>> callback) {
            invokeProviderMethod("onDisplayFieldsRequested", conversation, callback); // No I18N
        }

        private void invokeProviderMethod(
                @NonNull String methodName,
                @NonNull SalesIQConversation conversation,
                @NonNull DataProviderCallback<Map<String, String>> callback
        ) {
            final MethodChannel channel = providerChannel;
            if (channel == null) {
                callback.onResult(null);
                return;
            }

            final Map<String, Object> args = new HashMap<>();
            final Map<String, Object> conversationMap = MobilistenCorePlugin.getMap(conversation);
            args.put("conversation", conversationMap != null ? conversationMap : new HashMap<>()); // No I18N

            MobilistenCorePlugin.getHandler().post(() ->
                    channel.invokeMethod(methodName, args, new MethodChannel.Result() {
                        @Override
                        public void success(@Nullable Object result) {
                            callback.onResult(getStringMapOrNull(result));
                        }

                        @Override
                        public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                            callback.onResult(null);
                        }

                        @Override
                        public void notImplemented() {
                            callback.onResult(null);
                        }
                    })
            );
        }

        @Nullable
        private Map<String, String> getStringMapOrNull(@Nullable Object value) {
            if (!(value instanceof Map)) {
                return null;
            }
            Map<?, ?> resultMap = (Map<?, ?>) value;
            Map<String, String> stringMap = new HashMap<>();
            for (Map.Entry<?, ?> entry : resultMap.entrySet()) {
                if (entry.getKey() == null || entry.getValue() == null) {
                    continue;
                }
                stringMap.put(String.valueOf(entry.getKey()), String.valueOf(entry.getValue()));
            }
            return stringMap;
        }
    }

    private static @Nullable ChatComponent getChatComponent(final String componentName) {
        ChatComponent chatComponent = null;
        switch (componentName) {
            case "operator_image":
                chatComponent = ChatComponent.operatorImage;
                break;
            case "rating":
                chatComponent = ChatComponent.rating;
                break;
            case "feedback":
                chatComponent = ChatComponent.feedback;
                break;
            case "screenshot":
                chatComponent = ChatComponent.screenshot;
                break;
            case "pre_chat_form":
                chatComponent = ChatComponent.prechatForm;
                break;
            case "visitor_name":
                chatComponent = ChatComponent.visitorName;
                break;
            case "email_transcript":
                chatComponent = ChatComponent.emailTranscript;
                break;
            case "file_share":
                chatComponent = ChatComponent.fileShare;
                break;
            case "media_capture":
                chatComponent = ChatComponent.takePhoto;
                break;
            case "take_photo":
                chatComponent = ChatComponent.takePhoto;
                break;
            case "record_video":
                chatComponent = ChatComponent.recordVideo;
                break;
            case "media_library":
                chatComponent = ChatComponent.gallery;
                break;
            case "end":
                chatComponent = ChatComponent.end;
                break;
            case "end_when_in_queue":
                chatComponent = ChatComponent.endWhenInQueue;
                break;
            case "end_when_bot_connected":
                chatComponent = ChatComponent.endWhenBotConnected;
                break;
            case "end_when_operator_connected":
                chatComponent = ChatComponent.endWhenOperatorConnected;
                break;
            case "reopen":
                chatComponent = ChatComponent.reopen;
                break;
            case "call":
                chatComponent = ChatComponent.call;
                break;
            case "fileSharingWhenBotConnected":
                chatComponent = ChatComponent.fileSharingWhenBotConnected;
                break;
            case "voiceNoteWhenBotConnected":
                chatComponent = ChatComponent.voiceNoteWhenBotConnected;
                break;
            case "queue_position":
                chatComponent = ChatComponent.queuePosition;
                break;
            default:
        }
        return chatComponent;
    }

    static void handleConversationsMethodCalls(MethodCall call, Result result) {
        switch (call.method) {
            case "setAttribute": {
                SalesIQConversationAttributes attributes = MobilistenCorePlugin.getSalesIQConversationAttributes(call);
                ZohoSalesIQ.Conversation.setAttributes(builder -> attributes.toBuilder());
                break;
            }

            case "setDataProvider": {
                boolean shouldEnableSecretFields = false;
                boolean shouldEnableDisplayFields = false;
                Map<String, Object> providerConfig = MobilistenCorePlugin.getMapOrNull(call.arguments);
                if (providerConfig != null) {
                    shouldEnableSecretFields = LiveChatUtil.getBoolean(providerConfig.get("secretFieldsEnabled")); // No I18N
                    shouldEnableDisplayFields = LiveChatUtil.getBoolean(providerConfig.get("customInfoEnabled")); // No I18N
                }
                if (shouldEnableSecretFields || shouldEnableDisplayFields) {
                    SalesIQProviders.register(conversationsChannel);
                } else {
                    SalesIQProviders.unregister();
                }
                break;
            }

            case "setVisibility":
                ZohoSalesIQ.Conversation.setVisibility(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "fetchDepartments":
                ZohoSalesIQ.Conversation.getDepartments(new ZohoSalesIQResultCallback<List<SIQDepartment>>() {
                    @Override
                    public void onComplete(@NonNull SalesIQResult<List<SIQDepartment>> salesIQResult) {
                        List<SIQDepartment> departments = salesIQResult.getData();
                        if (departments == null) {
                            result.error(CONVERSATION_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null); // No I18N
                            return;
                        }
                        List<Map<String, Object>> departmentsMap = new ArrayList<>();
                        for (SIQDepartment department : departments) {
                            Map<String, Object> departmentMap = MobilistenCorePlugin.getMap(department);
                            String communicationModeString = (String) departmentMap.get("communicationMode");
                            if (communicationModeString != null && !communicationModeString.isEmpty()) {
                                departmentMap.put("communicationMode", MobilistenCorePlugin.convertToCamelCase(communicationModeString.toLowerCase()));
                            }
                            departmentsMap.add(departmentMap);
                        }
                        MobilistenCorePlugin.sendResult(salesIQResult, result, departmentsMap);
                    }
                });
                break;
        }
    }

    static void handleTrackingMethodCalls(MethodCall call, Result result) {
        switch (call.method) {
            case "performCustomAction":
                // Note: the native equivalent on Android is Visitor.performCustomAction(actionName).
                ZohoSalesIQ.Visitor.performCustomAction(LiveChatUtil.getString(call.arguments));
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    static void handleVisitorMethodCalls(MethodCall call, Result result) {
        switch (call.method) {
            case "updateVisitorProfile":
                updateVisitorProfile(call);
                result.success(null);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    static void handleHomepageMethodCalls(MethodCall call, Result result) {
        switch (call.method) {
            case "setHomepageEnabled":
                ZohoSalesIQ.Homepage.setEnabled(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "setHomepageWidgetVisibility": {
                ZohoSalesIQ.Homepage.Widget widget = getHomepageWidget(LiveChatUtil.getString(call.argument("widget")));    // No I18N
                if (widget != null) {
                    ZohoSalesIQ.Homepage.setVisibility(widget, LiveChatUtil.getBoolean(call.argument("visible")));  // No I18N
                } else {
                    LiveChatUtil.log("MobilistenPlugin - Invalid homepage widget type");    // No I18N
                }
                break;
            }

            default:
                result.notImplemented();
                break;
        }
    }

    static void handleHelpCenterMethodCalls(MethodCall call, Result result) {
        switch (call.method) {
            case "helpCenterAsk": {
                // The native question param is nullable, so pass it straight through and always
                // use the callback form to report the result.
                String question = MobilistenCorePlugin.getStringOrNull(call.arguments);
                ZohoSalesIQ.HelpCenter.ask(question, salesIQResult -> {
                    if (salesIQResult.isSuccess()) {
                        result.success(null);
                    } else {
                        SalesIQError error = salesIQResult.getError();
                        if (error != null) {
                            result.error(LiveChatUtil.getString(error.getCode()), error.getMessage(), null);
                        } else {
                            result.error(HELP_CENTER_ASK_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null);
                        }
                    }
                });
                break;
            }

            default:
                result.notImplemented();
                break;
        }
    }

    static void handleChatMethodCalls(MethodCall call, Result result) {
        switch (call.method) {
            case "showFeedbackAfterSkip": {
                ZohoSalesIQ.Chat.showFeedbackAfterSkip(LiveChatUtil.getBoolean(call.argument("enable")));   // No I18N
                break;
            }

            case "showFeedbackUpTo": {
                ZohoSalesIQ.Chat.showFeedback(LiveChatUtil.getInteger(call.argument("up_to_duration")));    // No I18N
                break;
            }

            case "showPayloadChat": {
                Map<String, Object> data = MobilistenCorePlugin.getMapOrNull(call.arguments);
                if (data == null) {
                    result.error(INVALID_PARAM_TYPE_CODE, INVALID_PARAM_TYPE, null);
                    return;
                }
                if ("endChatDetails".equals(data.get("type")) || "chat".equals(data.get("type"))) { // No I18N
                    Map<String, Object> payload = MobilistenCorePlugin.getMapOrNull(data.get("payload"));   // No I18N
                    if (payload != null && payload.containsKey("chatId")) {
                        PresentOptions.Builder presentOptions = new PresentOptions.Builder().setScreen(
                                new PresentOptions.Screen.Conversation(
                                        (String) payload.get("chatId"),
                                        PresentOptions.Screen.Conversation.SessionType.CHAT,
                                        PresentOptions.ConversationList.None
                                )
                        );
                        ZohoSalesIQ.present(presentOptions.build());    // No I18N
                    }
                }
                break;
            }

            case "hideQueueTime": {
                ZohoSalesIQ.Chat.hideQueueTime(LiveChatUtil.getBoolean(call.arguments));
                break;
            }

            case "setWaitingTime": {
                ZohoSalesIQ.Chat.setWaitingTime(LiveChatUtil.getInteger(call.arguments));
                break;
            }

            case "setTitle": {
                ZohoSalesIQ.Chat.setTitle(getStringOrNull(call.argument("onlineTitle")), getStringOrNull(call.argument("offlineTitle")));   // No I18N
                break;
            }

            case "getUnreadCount":
                //noinspection deprecation
                result.success(ZohoSalesIQ.Notification.getBadgeCount());
                break;

            case "startNewChat": {
                final boolean[] canSubmitCallback = {true};
                String departmentName = getStringOrNull(call.argument("department_name"));  //No I18N
                SalesIQConversationAttributes attributes = getSalesIQConversationAttributes(call, departmentName);
                ZohoSalesIQ.Chat.start(LiveChatUtil.getString(call.argument("question")), getStringOrNull(call.argument("custom_chat_id")), attributes, chatResult -> {  // No I18N
                    if (canSubmitCallback[0]) {
                        canSubmitCallback[0] = false;
                        if (chatResult.isSuccess()) {
                            result.success(getChatMapObject(chatResult.getData(), false));
                        } else {
                            SalesIQError salesIQError = chatResult.getError();
                            if (salesIQError != null) {
                                result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                            } else {
                                result.error(CHAT_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null); // No I18N
                            }
                        }
                    }
                });
                break;
            }

            case "initiateNewChatWithTrigger": {
                final boolean[] canSubmitCallback = {true};
                String departmentName = getStringOrNull(call.argument("department_name"));  //No I18N
                SalesIQConversationAttributes attributes = getSalesIQConversationAttributes(call, departmentName);
                ZohoSalesIQ.Chat.startWithTrigger(getString(call.argument("custom_action_name")), getStringOrNull(call.argument("custom_chat_id")), attributes, chatResult -> {  // No I18N
                    if (canSubmitCallback[0]) {
                        canSubmitCallback[0] = false;
                        if (chatResult.isSuccess() && chatResult.getData() != null) {
                            result.success(getChatMapObject(chatResult.getData(), false));
                        } else {
                            SalesIQError salesIQError = chatResult.getError();
                            if (salesIQError != null) {
                                result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                            } else {
                                result.error(CHAT_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null); // No I18N
                            }
                        }
                    }
                });
                break;
            }

            case "startNewChatWithTrigger": {
                final boolean[] canSubmitCallback = {true};
                //noinspection deprecation
                ZohoSalesIQ.Chat.startWithTrigger(getStringOrNull(call.argument("custom_chat_id")), getStringOrNull(call.argument("department_name")), chatResult -> {  // No I18N
                    if (canSubmitCallback[0]) {
                        canSubmitCallback[0] = false;
                        if (chatResult.isSuccess() && chatResult.getData() != null) {
                            result.success(getChatMapObject(chatResult.getData(), false));
                        } else {
                            SalesIQError salesIQError = chatResult.getError();
                            if (salesIQError != null) {
                                result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                            } else {
                                result.error(CHAT_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null); // No I18N
                            }
                        }
                    }
                });
                break;
            }

            case "getChat": {
                ZohoSalesIQ.Chat.get(LiveChatUtil.getString(call.argument("chat_id")), chatResult -> {
                    if (chatResult.isSuccess() && chatResult.getData() != null) {
                        result.success(getChatMapObject(chatResult.getData(), false));
                    } else {
                        SalesIQError salesIQError = chatResult.getError();
                        if (salesIQError != null) {
                            result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                        } else {
                            result.error(CHAT_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null); // No I18N
                        }
                    }
                });
                break;
            }

            case "setComponentVisibility": {
                ChatComponent chatComponent = getChatComponent(LiveChatUtil.getString(call.argument("component_name")));    // No I18N
                if (chatComponent != null) {
                    ZohoSalesIQ.Chat.setVisibility(chatComponent, LiveChatUtil.getBoolean(call.argument("visible")));   // No I18N
                }
                break;
            }

            case "setOfflineMessage": {
                // Note: Setting a custom offline message is an iOS-only native API
                // (ZohoSalesIQ.Chat.setOfflineMessage(message)); no Android equivalent.
                LiveChatUtil.log("MobilistenPlugin - setOfflineMessage is not supported on Android");    // No I18N
                break;
            }

        }
    }

    @Nullable
    private static SalesIQConversationAttributes getSalesIQConversationAttributes(MethodCall call, String departmentName) {
        SalesIQConversationAttributes.Builder builder;
        SalesIQConversationAttributes attributes = null;
        boolean hasDepartment = departmentName != null && !departmentName.isEmpty();
        boolean hasCustomSecretFields = call.hasArgument("custom_secret_fields") && call.argument("custom_secret_fields") != null && call.argument("custom_secret_fields") instanceof Map;  //No I18N
        if (departmentName != null && !departmentName.isEmpty() || hasCustomSecretFields) {
            builder = new SalesIQConversationAttributes.Builder();

            if (hasDepartment) {
                builder.setDepartments(Collections.singletonList(new SIQDepartment(null, departmentName, CommunicationMode.CHAT)));
            }
            if (hasCustomSecretFields) {
                Map<String, String> customFields = call.argument("custom_secret_fields");   //No I18N
                if (customFields != null) {
                    builder.setCustomSecretFields(customFields);
                }
            }
            attributes = builder.build();
        }
        return attributes;
    }

    static void handleKnowledgeBaseMethodCalls(MethodCall call, Result result) {
        boolean canExcludeResourceType = Objects.equals(call.method, "getResourceDepartments") || Objects.equals(call.method, "setRecentlyViewedCount");
        Integer type = !canExcludeResourceType && call.arguments != null ? call.argument("type") : null;   // No I18N
        ZohoSalesIQ.ResourceType resourceType = null;
        if (type != null && type == 0) {
            resourceType = ZohoSalesIQ.ResourceType.Articles;
        } else if (type != null && type == 1) {
            resourceType = ZohoSalesIQ.ResourceType.FAQs;
        }
        if (resourceType != null || canExcludeResourceType) {
            switch (call.method) {
                case "setVisibility": {
                    ZohoSalesIQ.KnowledgeBase.setVisibility(resourceType, LiveChatUtil.getBoolean(call.argument("should_show")));   // No I18N
                    break;
                }

                case "combineDepartments": {
                    ZohoSalesIQ.KnowledgeBase.combineDepartments(resourceType, LiveChatUtil.getBoolean(call.argument("merge")));    // No I18N
                    break;
                }

                case "categorize": {
                    ZohoSalesIQ.KnowledgeBase.categorize(resourceType, LiveChatUtil.getBoolean(call.argument("should_categorize")));    // No I18N
                    break;
                }

                case "setRecentlyViewedCount": {
                    ZohoSalesIQ.KnowledgeBase.setRecentlyViewedCount((Integer) call.arguments);
                    break;
                }

                case "isEnabled": {
                    result.success(ZohoSalesIQ.KnowledgeBase.isEnabled(resourceType));
                    break;
                }

                case "getSingleResource": {
                    boolean shouldFallbackToDefaultLanguage = !call.hasArgument("should_fallback_to_default_language") || LiveChatUtil.getBoolean(call.argument("should_fallback_to_default_language"));   // No I18N
                    ZohoSalesIQ.KnowledgeBase.getSingleResource(resourceType, LiveChatUtil.getString(call.argument("id")), shouldFallbackToDefaultLanguage, new ResourceListener() {   // No I18N
                        @Override
                        public void onSuccess(@Nullable Resource resource) {
                            result.success(getMap(resource));
                        }

                        @Override
                        public void onFailure(int code, @Nullable String message) {
                            result.error(LiveChatUtil.getString(code), message, null);
                        }
                    });
                    break;
                }

                case "getResources": {
                    boolean includeChildCategoryResources = LiveChatUtil.getBoolean(call.argument("include_child_category_resources"));   // No I18N
                    ZohoSalesIQ.KnowledgeBase.getResources(resourceType, getStringOrNull(call.argument("departmentId")), getStringOrNull(call.argument("parentCategoryId")), getStringOrNull(call.argument("searchKey")), includeChildCategoryResources, LiveChatUtil.getInteger(call.argument("page")), LiveChatUtil.getInteger(call.argument("limit")), new ResourcesListener() {  // No I18N
                        @Override
                        public void onSuccess(@NonNull List<Resource> resources, boolean moreDataAvailable) {
                            HashMap<String, Object> finalMap = new HashMap<>();
                            finalMap.put("resources", getMapList(resources));
                            finalMap.put("more_data_available", moreDataAvailable);
                            result.success(finalMap);
                        }

                        @Override
                        public void onFailure(int code, @Nullable String message) {
                            result.error(LiveChatUtil.getString(code), message, null);
                        }
                    });
                    break;
                }

                case "getResourceDepartments": {
                    ZohoSalesIQ.KnowledgeBase.getResourceDepartments(new ResourceDepartmentsListener() {
                        @Override
                        public void onSuccess(@NonNull List<ResourceDepartment> resourceDepartments) {
                            result.success(getMapList(resourceDepartments));
                        }

                        @Override
                        public void onFailure(int code, @Nullable String message) {
                            result.error(LiveChatUtil.getString(code), message, null);
                        }
                    });
                    break;
                }

                case "getCategories": {
                    ZohoSalesIQ.KnowledgeBase.getCategories(resourceType, getStringOrNull(call.argument("departmentId")), getStringOrNull(call.argument("parentCategoryId")), new ResourceCategoryListener() {    // No I18N
                        @Override
                        public void onSuccess(@NonNull List<ResourceCategory> resourceCategories) {
                            result.success(getMapList(resourceCategories));
                        }

                        @Override
                        public void onFailure(int code, @Nullable String message) {
                            result.error(LiveChatUtil.getString(code), message, null);
                        }
                    });
                    break;
                }

                case "openResource": {
                    ZohoSalesIQ.KnowledgeBase.open(resourceType, LiveChatUtil.getString(call.argument("id")), new OpenResourceListener() {  // No I18N
                        @Override
                        public void onSuccess() {
                            result.success(Boolean.TRUE);
                        }

                        @Override
                        public void onFailure(int code, @Nullable String message) {
                            result.error(LiveChatUtil.getString(code), message, null);
                        }
                    });
                    break;
                }
            }
        } else {
            result.error(INVALID_RESOURCE_TYPE_CODE, "Invalid resource type", null); // No I18N
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result rawResult) {
        final Result finalResult = rawResult;
        switch (call.method) {
            case "init":
                registerCallbacks(application);
                boolean isNewInitializationFlow = LiveChatUtil.getBoolean(call.argument("isNewInitializationFlow")); // No I18N
                if (isNewInitializationFlow) {
                    initializeSalesIQ(application, activity, call, finalResult);
                } else {
                    String appKey = LiveChatUtil.getString(call.argument("appKey"));         // No I18N
                    String accessKey = LiveChatUtil.getString(call.argument("accessKey"));         // No I18N
                    initSalesIQ(application, activity, appKey, accessKey, finalResult);
                }
                ZohoSalesIQ.setPlatformName(SalesIQConstants.Platform.FLUTTER_ANDROID);
                break;

            case "setCustomFont":
                Map<String, Object> regular = call.argument("regular"); // No I18N
                Map<String, Object> medium = call.argument("medium");   // No I18N
                String regularPath = regular != null ? LiveChatUtil.getString(regular.get("path")) : null;    // No I18N
                String mediumPath = medium != null ? LiveChatUtil.getString(medium.get("path")) : null;   // No I18N
                if (regularPath != null || mediumPath != null) {
                    customFont = new Font();
                    customFont.regular = regularPath;
                    customFont.medium = mediumPath;
                } else {
                    customFont = null;
                }
                break;

            case "showLauncher":
                ZohoSalesIQ.Launcher.show(LiveChatUtil.getBoolean(call.arguments)
                        ? ZohoSalesIQ.Launcher.VisibilityMode.ALWAYS
                        : ZohoSalesIQ.Launcher.VisibilityMode.NEVER);
                break;

            case "setLanguage":
                ZohoSalesIQ.Chat.setLanguage(LiveChatUtil.getString(call.arguments));
                break;

            case "setDepartment":
                ZohoSalesIQ.Chat.setDepartment(LiveChatUtil.getString(call.arguments));
                break;

            case "setDepartments":
                ArrayList<String> list = MobilistenCorePlugin.getArrayListOrNull(call.arguments);
                if (list == null) {
                    return;
                }
                ZohoSalesIQ.Chat.setDepartments(list);
                break;

            case "getCommunicationMode":
                finalResult.success(getCommunicationMode(ZohoSalesIQ.getCommunicationMode()));
                break;

            case "setQuestion":
                ZohoSalesIQ.Chat.setQuestion(LiveChatUtil.getString(call.arguments));
                break;

            case "startChat":
                ZohoSalesIQ.Chat.start(LiveChatUtil.getString(call.arguments));
                break;

            case "setConversationVisibility":
                ZohoSalesIQ.Conversation.setVisibility(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "setConversationListTitle":
                ZohoSalesIQ.Conversation.setTitle(LiveChatUtil.getString(call.arguments));
                break;

            case "registerVisitor":
                ZohoSalesIQ.registerVisitor(LiveChatUtil.getString(call.arguments), new RegisterListener() {
                    @Override
                    public void onSuccess() {
                        ZohoSalesIQ.Chat.setVisibility(ChatComponent.screenshot, false);
                        finalResult.success("Success");    //No I18N
                    }

                    @Override
                    public void onFailure(int errorCode, String errorMessage) {
                        finalResult.error(LiveChatUtil.getString(errorCode), errorMessage, null);
                    }
                });
                break;

            case "unregisterVisitor":  //need to pass the current activity
                ZohoSalesIQ.unregisterVisitor(activity, new UnRegisterListener() {//need to pass the current activity
                    @Override
                    public void onSuccess() {
                        ZohoSalesIQ.Chat.setVisibility(ChatComponent.screenshot, false);
                        finalResult.success("Success");    //No I18N
                    }

                    @Override
                    public void onFailure(int code, String message) {
                        ZohoSalesIQ.Chat.setVisibility(ChatComponent.screenshot, false);
                        finalResult.error(LiveChatUtil.getString(code), message, null);
                    }
                });
                break;

            case "setPageTitle":
                ZohoSalesIQ.Tracking.setPageTitle(LiveChatUtil.getString(call.arguments));
                break;

            case "performCustomAction":
                String customActionName = LiveChatUtil.getString(call.argument("action_name")); // No I18N
                ZohoSalesIQ.Visitor.performCustomAction(customActionName);
                break;

            case "enableInAppNotification":
                if (LiveChatUtil.getBoolean(call.arguments)) {
                    ZohoSalesIQ.Notification.enableInApp();
                } else {
                    ZohoSalesIQ.Notification.disableInApp();
                }
                break;

            case "setOperatorEmail":
                try {
                    ZohoSalesIQ.Chat.setOperatorEmail(LiveChatUtil.getString(call.arguments));
                } catch (InvalidEmailException e) {
                    finalResult.error("10001", e.getMessage(), null);         // No I18N
                }
                break;

            case "show":
                ZohoSalesIQ.present();
                break;

            case "openNewChat":
                ZohoSalesIQ.present(new PresentOptions(
                        new PresentOptions.Screen.Conversation(
                                PresentOptions.ConversationList.None,
                                new PresentOptions.Screen.Conversation.SessionBehavior.AlwaysNew(
                                        PresentOptions.Screen.Conversation.SessionType.CHAT))));
                break;

            case "showOfflineMessage":
                ZohoSalesIQ.Chat.showOfflineMessage(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "end":
                ZohoSalesIQ.Chat.endChat(LiveChatUtil.getString(call.arguments));
                break;

            case "setVisitorName":
                ZohoSalesIQ.Visitor.setName(LiveChatUtil.getString(call.arguments));
                break;

            case "setVisitorEmail":
                ZohoSalesIQ.Visitor.setEmail(LiveChatUtil.getString(call.arguments));
                break;

            case "setVisitorContactNumber":
                ZohoSalesIQ.Visitor.setContactNumber(LiveChatUtil.getString(call.arguments));
                break;

            case "setVisitorAddInfo":
                String key = LiveChatUtil.getString(call.argument("key"));         // No I18N
                String value = LiveChatUtil.getString(call.argument("value"));         // No I18N
                ZohoSalesIQ.Visitor.addInfo(key, value);
                break;

            case "setVisitorLocation":
                if (call.arguments instanceof Map) {
                    SIQVisitorLocation siqVisitorLocation = null;
                    Map<String, Object> visitorLocation = MobilistenCorePlugin.getMapOrNull(call.arguments);
                    if (visitorLocation != null) {
                        siqVisitorLocation = new SIQVisitorLocation();
                        if (visitorLocation.containsKey("latitude")) {
                            siqVisitorLocation.setLatitude(LiveChatUtil.getDouble(visitorLocation.get("latitude")));         // No I18N
                        }
                        if (visitorLocation.containsKey("longitude")) {
                            siqVisitorLocation.setLongitude(LiveChatUtil.getDouble(visitorLocation.get("longitude")));         // No I18N
                        }
                        if (visitorLocation.containsKey("country")) {
                            siqVisitorLocation.setCountry(LiveChatUtil.getString(visitorLocation.get("country")));         // No I18N
                        }
                        if (visitorLocation.containsKey("city")) {
                            siqVisitorLocation.setCity(LiveChatUtil.getString(visitorLocation.get("city")));         // No I18N
                        }
                        if (visitorLocation.containsKey("state")) {
                            siqVisitorLocation.setState(LiveChatUtil.getString(visitorLocation.get("state")));         // No I18N
                        }
                        if (visitorLocation.containsKey("countryCode")) {
                            siqVisitorLocation.setCountryCode(LiveChatUtil.getString(visitorLocation.get("countryCode")));         // No I18N
                        }
                        if (visitorLocation.containsKey("zipCode")) {
                            siqVisitorLocation.setZipCode(LiveChatUtil.getString(visitorLocation.get("zipCode")));         // No I18N
                        }
                    }
                    ZohoSalesIQ.Visitor.setLocation(siqVisitorLocation);
                }
                break;

            case "setChatTitle":
                //noinspection deprecation
                ZohoSalesIQ.Chat.setTitle(LiveChatUtil.getString(call.arguments));
                break;

            case "showOperatorImageInLauncher":
                ZohoSalesIQ.Chat.showOperatorImageInLauncher(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "showOperatorImageInChat":
                ZohoSalesIQ.Chat.setVisibility(ChatComponent.operatorImage, LiveChatUtil.getBoolean(call.arguments));
                break;

            case "setVisitorNameVisibility":
                ZohoSalesIQ.Chat.setVisibility(ChatComponent.visitorName, LiveChatUtil.getBoolean(call.arguments));
                break;

            case "setFeedbackVisibility":
                ZohoSalesIQ.Chat.setVisibility(ChatComponent.feedback, LiveChatUtil.getBoolean(call.arguments));
                break;

            case "setRatingVisibility":
                ZohoSalesIQ.Chat.setVisibility(ChatComponent.rating, LiveChatUtil.getBoolean(call.arguments));
                break;

            case "enablePreChatForms":
                ZohoSalesIQ.Chat.setVisibility(ChatComponent.prechatForm, true);
                break;

            case "disablePreChatForms":
                ZohoSalesIQ.Chat.setVisibility(ChatComponent.prechatForm, false);
                break;

            case "getDepartments":
                handler.post(new Runnable() {
                    public void run() {
                        ZohoSalesIQ.Chat.getDepartments(new DepartmentListener() {
                            @Override
                            public void onSuccess(ArrayList<SIQDepartment> arrayList) {
                                if (arrayList != null) {
                                    final List<Map<String, Object>> departmentList = new ArrayList<Map<String, Object>>();
                                    for (int i = 0; i < arrayList.size(); i++) {
                                        Map<String, Object> chatMapObject = getDepartmentMapObject(arrayList.get(i));
                                        departmentList.add(chatMapObject);
                                    }
                                    handler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            finalResult.success(departmentList);
                                        }
                                    });
                                }
                            }

                            @Override
                            public void onFailure(final int errorCode, final String errorMessage) {
                                handler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        finalResult.error(LiveChatUtil.getString(errorCode), errorMessage, null);
                                    }
                                });
                            }
                        });
                    }
                });
                break;

            case "getChats":
                ZohoSalesIQ.Chat.getList(new ConversationListener() {
                    @Override
                    public void onSuccess(ArrayList<VisitorChat> arrayList) {
                        List<Map<String, Object>> chatList = new ArrayList<Map<String, Object>>();
                        for (int i = 0; i < arrayList.size(); i++) {
                            Map<String, Object> chatMapObject = getChatMapObject(arrayList.get(i), false);
                            chatList.add(chatMapObject);
                        }
                        finalResult.success(chatList);
                    }

                    @Override
                    public void onFailure(int errorCode, String errorMessage) {
                        finalResult.error(LiveChatUtil.getString(errorCode), errorMessage, null);
                    }
                });
                break;

            case "getChatsWithFilter":
                String filter = call.arguments.toString();
                if (isValidFilterName(filter)) {
                    ConversationType filterName = getFilterName(filter);
                    ZohoSalesIQ.Chat.getList(filterName, new ConversationListener() {
                        @Override
                        public void onSuccess(ArrayList<VisitorChat> arrayList) {
                            List<Map<String, Object>> chatList = new ArrayList<Map<String, Object>>();
                            for (int i = 0; i < arrayList.size(); i++) {
                                Map<String, Object> chatMapObject = getChatMapObject(arrayList.get(i), false);
                                chatList.add(chatMapObject);
                            }
                            finalResult.success(chatList);
                        }

                        @Override
                        public void onFailure(int errorCode, String message) {
                            finalResult.error(LiveChatUtil.getString(errorCode), message, null);
                        }
                    });
                } else {
                    finalResult.error(INVALID_FILTER_CODE, INVALID_FILTER_TYPE, null);
                }
                break;

            case "fetchAttenderImage":
                String attenderID = LiveChatUtil.getString(call.argument("attenderID"));         // No I18N
                boolean fetchDefaultImage = LiveChatUtil.getBoolean(call.argument("fetchDefaultImage"));         // No I18N
                ZohoSalesIQ.Chat.fetchAttenderImage(attenderID, fetchDefaultImage, new OperatorImageListener() {
                    @Override
                    public void onSuccess(Drawable drawable) {
                        Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();

                        ByteArrayOutputStream baos = new ByteArrayOutputStream();
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos); //bm is the bitmap object
                        byte[] byteArrayImage = baos.toByteArray();

                        String encodedImage = Base64.encodeToString(byteArrayImage, Base64.DEFAULT);

                        encodedImage = encodedImage.replace("\n", "");         // No I18N

                        finalResult.success(encodedImage);
                    }

                    @Override
                    public void onFailure(int errorCode, String errorMessage) {
                        finalResult.error("" + errorCode, errorMessage, null);
                    }
                });
                break;

            case "registerChatAction":
                ZohoSalesIQ.ChatActions.register(LiveChatUtil.getString(call.arguments));
                break;

            case "unregisterChatAction":
                ZohoSalesIQ.ChatActions.unregister(LiveChatUtil.getString(call.arguments));
                break;

            case "unregisterAllChatActions":
                ZohoSalesIQ.ChatActions.unregisterAll();
                break;

            case "setChatActionTimeout":
                Long timeout = LiveChatUtil.getLong(call.arguments);
                handler.post(new Runnable() {
                    public void run() {
                        ZohoSalesIQ.ChatActions.setTimeout(timeout * 1000);
                    }
                });
                break;

            case "completeChatAction":
                final String actionID = LiveChatUtil.getString(call.arguments);
                handler.post(new Runnable() {
                    public void run() {
                        SalesIQCustomActionListener listener;
                        listener = ACTIONS_LIST.get(actionID);
                        if (listener != null) {
                            listener.onSuccess();
                        }
                        if (ACTIONS_LIST != null) {
                            ACTIONS_LIST.remove(actionID);
                        }
                    }
                });
                break;

            case "completeChatActionWithMessage":
                final String actionId = LiveChatUtil.getString(call.argument("actionUUID"));         // No I18N
                final boolean state = LiveChatUtil.getBoolean(call.argument("state"));         // No I18N
                final String message = LiveChatUtil.getString(call.argument("message"));         // No I18N
                Handler handler1 = new Handler(Looper.getMainLooper());
                handler1.post(new Runnable() {
                    public void run() {
                        SalesIQCustomActionListener listener = ACTIONS_LIST.get(actionId);
                        if (listener != null) {
                            if (state) {
                                if (message != null && message.length() > 0) {
                                    listener.onSuccess(message);
                                } else {
                                    listener.onSuccess();
                                }
                            } else {
                                if (message != null && message.length() > 0) {
                                    listener.onFailure(message);
                                } else {
                                    listener.onFailure();
                                }
                            }
                        }
                        if (ACTIONS_LIST != null) {
                            ACTIONS_LIST.remove(actionId);
                        }
                    }
                });
                break;

            case "isMultipleOpenChatRestricted":
                finalResult.success(ZohoSalesIQ.Chat.isMultipleOpenRestricted());
                break;

            case "getChatUnreadCount":
                //noinspection deprecation
                finalResult.success(ZohoSalesIQ.Notification.getBadgeCount());
                break;
            case "setThemeForAndroid": {
                int resourceId = getStyleResourceId(LiveChatUtil.getString(call.arguments));
                if (resourceId > 0) {
                    ZohoSalesIQ.setTheme(resourceId);
                }
                break;
            }
            case "shouldOpenUrl":
                Boolean boolValue = MobilistenCorePlugin.getBooleanOrNull(call.arguments);
                if (boolValue == null) {
                    return;
                }
                shouldOpenUrl(boolValue);
                break;
            case "sendEvent":
                sendEvent((String) call.argument("eventName"), (ArrayList) call.argument("values"));    // No I18N
                break;
            case "isLoggerEnabled":
                isLoggerEnabled(finalResult);
                break;
            case "setLoggerEnabled":
                setLoggerEnabled((Boolean) call.arguments);
                break;
            case "setLauncherPropertiesForAndroid":
                Map<String, Object> map = MobilistenCorePlugin.getMapOrNull(call.arguments);
                if (map == null) {
                    rawResult.error(INVALID_PARAM_TYPE_CODE, INVALID_PARAM_TYPE, null);
                    return;
                }
                setLauncherPropertiesForAndroid(map);
                break;
            case "syncThemeWithOSForAndroid":
                boolValue = MobilistenCorePlugin.getBooleanOrNull(call.arguments);
                if (boolValue == null) {
                    return;
                }
                ZohoSalesIQ.syncThemeWithOS(boolValue);
                break;
            case "dismissUI":
                ZohoSalesIQ.dismissUI();
                break;
            case "refreshLauncher":
                LauncherUtil.refreshLauncher();
                break;
            case "setSessionID":
                ZohoSalesIQ.setSessionID(LiveChatUtil.getString(call.arguments));
                break;
            case "setAndroidUriScheme":
                Map<String, Object> uriSchemeMap = MobilistenCorePlugin.getMapOrNull(call.arguments);
                if (uriSchemeMap == null) {
                    rawResult.error(INVALID_PARAM_TYPE_CODE, INVALID_PARAM_TYPE, null);
                    return;
                }
                setUriScheme(uriSchemeMap);
                break;
            case "refreshData": {
                String type = getStringOrNull(call.argument("type")); // No I18N
                String conversationId = getStringOrNull(call.argument("conversationId")); // No I18N
                if (type == null || conversationId == null || conversationId.isEmpty()) {
                    rawResult.error(INVALID_PARAM_TYPE_CODE, INVALID_PARAM_TYPE, null);
                    return;
                }
                SalesIQData data = getRefreshData(type, conversationId);
                if (data == null) {
                    rawResult.error(INVALID_PARAM_TYPE_CODE, INVALID_PARAM_TYPE, null);
                    return;
                }
                ZohoSalesIQ.refreshData(data);
                break;
            }
            case "updateConfiguration":
                updateConfiguration(call.argument("key"), call.argument("value"));  // No I18N
                break;

            case "presentScreen":
                presentScreen(call, finalResult);
                break;

            case "setThemeSource": {
                String themeSourceName = LiveChatUtil.getString(call.arguments);
                if ("portal".equals(themeSourceName)) {  // No I18N
                    ZohoSalesIQ.setThemeSource(ZohoSalesIQ.ThemeSource.SalesIQPortalConfiguration);
                } else if ("sdk".equals(themeSourceName)) {  // No I18N
                    ZohoSalesIQ.setThemeSource(ZohoSalesIQ.ThemeSource.SdkConfiguration);
                } else {
                    LiveChatUtil.log("MobilistenPlugin - Invalid theme source: " + themeSourceName);    // No I18N
                }
                break;
            }

            case "setThemeColorForiOS":
            case "writeLogForiOS":
            case "clearLogForiOS":
            case "setPathForiOS":
            case "registerLocalizationFileForiOS":
                break;

            case "reRegisterPush":
                // iOS only: re-registers the device for push via
                // ZohoSalesIQ.reregisterPushNotification(). The Android native SDK has no
                // equivalent API, so this is a no-op here (mirrors the RN Android wrapper).
                finalResult.success(null);
                break;

            default:
                finalResult.notImplemented();
                break;
        }
    }

    private static void setUriScheme(@NonNull Map<String, Object> uriSchemeMap) {
        Object schemeObject = uriSchemeMap.get("scheme");
        Object hostsObject = uriSchemeMap.get("hosts");
        Object pathsObject = uriSchemeMap.get("paths");

        String scheme = schemeObject != null ? LiveChatUtil.getString(schemeObject) : null;
        List<String> hosts = MobilistenCorePlugin.getListOrNull(hostsObject);
        List<Map<String, Object>> paths = MobilistenCorePlugin.getListOrNull(pathsObject);
        if (scheme != null && !scheme.isEmpty()) {
            SalesIQUriScheme uriScheme = new SalesIQUriScheme(scheme);
            if (hosts != null && !hosts.isEmpty()) {
                uriScheme.addHosts(hosts.toArray(new String[0]));
            }
            if (paths != null && !paths.isEmpty()) {
                for (Map<String, Object> pathMap : paths) {
                    String type = pathMap.get("type") != null ? LiveChatUtil.getString(pathMap.get("type")) : null; // No I18N
                    String value = pathMap.get("value") != null ? LiveChatUtil.getString(pathMap.get("value")) : null; // No I18N
                    if (type != null && !type.isEmpty() && value != null && !value.isEmpty()) {
                        SalesIQUriScheme.PathMatcher pathMatcher = null;
                        switch (type) {
                            case "exact": {
                                pathMatcher = new SalesIQUriScheme.PathMatcher.Exact(value);
                                break;
                            }

                            case "prefix": {
                                pathMatcher = new SalesIQUriScheme.PathMatcher.Prefix(value);
                                break;
                            }

                            case "suffix": {
                                pathMatcher = new SalesIQUriScheme.PathMatcher.Suffix(value);
                                break;
                            }

                            case "pattern": {
                                pathMatcher = new SalesIQUriScheme.PathMatcher.Pattern(value);
                                break;
                            }
                        }
                        if (pathMatcher != null) {
                            uriScheme.addPaths(pathMatcher);
                        }
                    }
                }
            }
            ZohoSalesIQ.setUriScheme(uriScheme);
        }
    }

    private static void updateConfiguration(String key, Object value) {
        String configurationKey;
        if ("NeutralRatingDisabled".equals(key)) {
            configurationKey = "binaryRating";  // No I18N
        } else if ("ChatBotCarousalCardPropertiesOrientation".equals(key)) {
            configurationKey = "chat_bot_carousal_card_properties_orientation"; // No I18N
        } else if ("ChatBotCarousalCardImageVisibility".equals(key)) {
            configurationKey = "chat_bot_carousal_card_image_visibility";   // No I18N
        } else if ("ChatFallbackDepartmentsOnReopenIfOffline".equals(key)) {
            configurationKey = "fallbackDepartmentsOnReopenIfOffline";   // No I18N
        } else {
            SalesIQConfig config = null;
            if ("IncludeVisitorInfoInConversationInfo".equals(key)) {
                config = new SalesIQConfig.IncludeVisitorInfoWithDisplayFields(LiveChatUtil.getBoolean(value));
            } else if ("HideCreditCardMaskingConsentAlert".equals(key)) {
                config = new SalesIQConfig.BypassCreditCardMaskingConsent(LiveChatUtil.getBoolean(value));
            } else if ("SecretFieldsProviderTimeout".equals(key)) {
                ZohoSalesIQ.setTimeout(SalesIQTimeoutType.SECRET_FIELDS, LiveChatUtil.getLong(value));
            } else if ("DisplayFieldsProviderTimeout".equals(key)) {
                ZohoSalesIQ.setTimeout(SalesIQTimeoutType.DISPLAY_FIELDS, LiveChatUtil.getLong(value));
            } else if ("EnableHomePageBackStackForChatInitiation".equals(key)) {
                config = new SalesIQConfig.EnableHomePageBackStackForChatInitiation(LiveChatUtil.getBoolean(value));
            }
            if (config != null) {
                ZohoSalesIQ.setConfig(config);
            }
            return;
        }
        System.setProperty(configurationKey, value.toString());
    }

    @Nullable
    private static SalesIQData getRefreshData(@NonNull String type, @NonNull String conversationId) {
        switch (type) {
            case "secretFields":
                return new SalesIQData.SecretFields(conversationId);
            case "displayFields":
                return new SalesIQData.DisplayFields(conversationId);
            default:
                return null;
        }
    }

    private static void handleVisitorRegistrationFailure(HashMap<String, Object> map) {
        if (map.containsKey("type")) {
            String type = (String) map.get("type");
            String userId = (String) map.get("user_id");
            if ("registered_visitor".equals(type)) {
                if (userId != null && !TextUtils.isEmpty(userId)) {
                    LiveChatUtil.log("MobilistenEncryptedSharedPreferences- re-registering visitor");   // No I18N
                    try {
                        LiveChatUtil.registerVisitor(userId, null, new RegisterListener() {
                            @Override
                            public void onSuccess() {
                                LoggerUtil.logDebugInfo(new DebugInfoData.VisitorFailureReRegistrationAcknowledged(userId));
                                LiveChatUtil.log("MobilistenEncryptedSharedPreferences- re-registering visitor success");   // No I18N
                                if (DataModule.getSharedPreferences().contains(MobilistenEncryptedSharedPreferences.ARE_NEW_ENCRYPTED_KEYS_PRESENT_IN_DEFAULT_PREFERENCES) && DataModule.getSharedPreferences().getBoolean(MobilistenEncryptedSharedPreferences.ARE_NEW_ENCRYPTED_KEYS_PRESENT_IN_DEFAULT_PREFERENCES, true)) {
                                    if (DeviceConfig.getPreferences() != null) {
                                        DeviceConfig.getPreferences().edit().putBoolean(CommonPreferencesLocalDataSource.SharedPreferenceKeys.IsEncryptedSharedPreferenceFailureAcknowledged, true).commit();
                                    }
                                } else {
                                    DataModule.getSharedPreferences().edit().remove(CommonPreferencesLocalDataSource.SharedPreferenceKeys.IsEncryptedSharedPreferenceFailureAcknowledged).commit();
                                }
                            }

                            @Override
                            public void onFailure(int code, String message) {

                            }
                        });
                    } catch (InvalidVisitorIDException e) {
                        LiveChatUtil.log(e);
                    }
                }
            } else if ("guest".equals(type)) {
                LiveChatUtil.log("MobilistenEncryptedSharedPreferences- Guest user acknowledged");
                JSONObject jsonObject = new JSONObject();
                try {
                    jsonObject.put("avuid", LiveChatUtil.getAVUID());
                } catch (Exception e) {
                    LiveChatUtil.log(e);
                }
                LoggerUtil.logDebugInfo(new DebugInfoData.VisitorFailureGuestAcknowledged(jsonObject.toString()));
                if (DataModule.getSharedPreferences().contains(MobilistenEncryptedSharedPreferences.ARE_NEW_ENCRYPTED_KEYS_PRESENT_IN_DEFAULT_PREFERENCES) && DataModule.getSharedPreferences().getBoolean(MobilistenEncryptedSharedPreferences.ARE_NEW_ENCRYPTED_KEYS_PRESENT_IN_DEFAULT_PREFERENCES, true)) {
                    if (DeviceConfig.getPreferences() != null) {
                        DeviceConfig.getPreferences().edit().putBoolean(CommonPreferencesLocalDataSource.SharedPreferenceKeys.IsEncryptedSharedPreferenceFailureAcknowledged, true).commit();
                    }
                } else {
                    DataModule.getSharedPreferences().edit().remove(CommonPreferencesLocalDataSource.SharedPreferenceKeys.IsEncryptedSharedPreferenceFailureAcknowledged).commit();
                }
            }
        }
    }

    private static void initSalesIQ(final Application application, final Activity activity, final String appKey, final String accessKey, final Result result) {
        final boolean[] isCallBackInvoked = {false};
        if (application != null) {
            try {
                InitConfig initConfig = null;
                if (customFont != null) {
                    initConfig = new InitConfig();
                    initConfig.setFont(Fonts.REGULAR, customFont.regular);
                    initConfig.setFont(Fonts.MEDIUM, customFont.medium);
                }
                ZohoSalesIQ.init(application, appKey, accessKey, activity, initConfig, new InitListener() {
                    @Override
                    public void onInitSuccess() {
                        LauncherUtil.refreshLauncher();

                        if (fcmtoken != null) {
                            ZohoSalesIQ.Notification.enablePush(fcmtoken, istestdevice);
                        }
                        ZohoSalesIQ.Chat.setVisibility(ChatComponent.screenshot, false);
                        Handler handler = new Handler(Looper.getMainLooper());
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (result != null && !isCallBackInvoked[0]) {
                                    isCallBackInvoked[0] = true;
                                    result.success("InitSuccess");         // No I18N
                                }
                            }
                        });
                    }

                    @Override
                    public void onInitError(final int errorCode, final String errorMessage) {
                        Handler handler = new Handler(Looper.getMainLooper());
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (result != null && !isCallBackInvoked[0]) {
                                    isCallBackInvoked[0] = true;
                                    result.error(LiveChatUtil.getString(errorCode), errorMessage, null);
                                }
                            }
                        });
                    }
                });
            } catch (Exception e) {
                LiveChatUtil.log(e);
            }
        }
    }

    private static @Nullable SalesIQConfiguration.SalesIQCallViewMode getCallViewMode(@Nullable String mode) {
        if (mode == null || mode.isEmpty()) {
            return null;
        }
        SalesIQConfiguration.SalesIQCallViewMode callViewMode = null;
        for (SalesIQConfiguration.SalesIQCallViewMode entry : SalesIQConfiguration.SalesIQCallViewMode.getEntries()) {
            if (entry.name().equalsIgnoreCase(mode)) {
                callViewMode = entry;
                break;
            }
        }
        return callViewMode;
    }

    private static void initializeSalesIQ(final Application application, final Activity activity, @NonNull MethodCall call, final Result result) {
        final boolean[] isCallBackInvoked = {false};
        if (application != null) {
            try {
                String appKey = LiveChatUtil.getString(call.argument("appKey"));         // No I18N
                String accessKey = LiveChatUtil.getString(call.argument("accessKey"));         // No I18N
                @Nullable String callViewModeString = LiveChatUtil.getString(call.argument("callViewMode"));         // No I18N
                SalesIQConfiguration.Builder builder = new SalesIQConfiguration.Builder(appKey, accessKey);
                SalesIQConfiguration.SalesIQCallViewMode callViewMode = getCallViewMode(callViewModeString);
                if (callViewMode != null) {
                    builder.setCallViewMode(callViewMode);
                }

                Map<String, Object> fontsMap = MobilistenCorePlugin.getMapOrNull(call.argument("fonts"));  // No I18N
                Map<String, Object> regularFontMap = fontsMap != null ? MobilistenCorePlugin.getMapOrNull(fontsMap.get("regular")) : null;    // No I18N
                Map<String, Object> mediumFontMap = fontsMap != null ? MobilistenCorePlugin.getMapOrNull(fontsMap.get("medium")) : null;    // No I18N
                String regularFontPath = regularFontMap != null ? getStringOrNull(regularFontMap.get("path")) : null;   // No I18N
                String mediumFontPath = mediumFontMap != null ? getStringOrNull(mediumFontMap.get("path")) : null;   // No I18N
                if (regularFontPath == null && customFont != null) {
                    regularFontPath = customFont.regular;
                }
                if (mediumFontPath == null && customFont != null) {
                    mediumFontPath = customFont.medium;
                }
                if (regularFontPath != null) {
                    builder.setFont(Fonts.REGULAR, regularFontPath);
                }
                if (mediumFontPath != null) {
                    builder.setFont(Fonts.MEDIUM, mediumFontPath);
                }
                ZohoSalesIQ.initialize(application, builder.build(), salesIQResult -> {
                    Handler handler = new Handler(Looper.getMainLooper());
                    if (salesIQResult.isSuccess()) {
                        if (fcmtoken != null) {
                            ZohoSalesIQ.Notification.enablePush(fcmtoken, istestdevice);
                        }
                        ZohoSalesIQ.Chat.setVisibility(ChatComponent.screenshot, false);
                        handler.post(() -> {
                            if (result != null && !isCallBackInvoked[0]) {
                                isCallBackInvoked[0] = true;
                                result.success("InitSuccess");         // No I18N
                            }
                        });
                    } else {
                        SalesIQError error = salesIQResult.getError();
                        String errorCode = error != null ? LiveChatUtil.getString(error.getCode()) : "-1000"; // No I18N — wrapper unknown-error fallback (matches iOS ErrorCode.unknown)
                        String errorMessage = error != null ? error.getMessage() : "Unknown error"; // No I18N
                        handler.post(() -> {
                            if (result != null && !isCallBackInvoked[0]) {
                                isCallBackInvoked[0] = true;
                                result.error(LiveChatUtil.getString(errorCode), errorMessage, null);
                            }
                        });
                    }
                });
            } catch (Exception e) {
                LiveChatUtil.log(e);
            }
        }
    }

    private static void updateVisitorProfile(@NonNull MethodCall call) {
        SalesIQVisitorProfile profile = new SalesIQVisitorProfile();
        String salutation = getStringOrNull(call.argument("salutation"));   // No I18N
        if (salutation != null) {
            switch (salutation) {
                case "mr":
                    profile.setSalutation(SalesIQVisitorProfile.Salutation.Mr);
                    break;
                case "ms":
                    profile.setSalutation(SalesIQVisitorProfile.Salutation.Ms);
                    break;
                case "mrs":
                    profile.setSalutation(SalesIQVisitorProfile.Salutation.Mrs);
                    break;
                case "dr":
                    profile.setSalutation(SalesIQVisitorProfile.Salutation.Dr);
                    break;
                case "prof":
                    profile.setSalutation(SalesIQVisitorProfile.Salutation.Prof);
                    break;
                default:
                    profile.setSalutation(SalesIQVisitorProfile.Salutation.None);
            }
        }
        profile.setFirstName(getStringOrNull(call.argument("firstName")));   // No I18N
        profile.setLastName(getStringOrNull(call.argument("lastName")));   // No I18N
        profile.setEmail(getStringOrNull(call.argument("email")));   // No I18N
        // Note: userID is an iOS-only profile property; ignored here.
        Map<String, Object> phoneMap = MobilistenCorePlugin.getMapOrNull(call.argument("phone"));   // No I18N
        if (phoneMap != null) {
            String code = getStringOrNull(phoneMap.get("code"));   // No I18N
            String number = getStringOrNull(phoneMap.get("number"));   // No I18N
            if ((code != null && !code.isEmpty()) || (number != null && !number.isEmpty())) {
                profile.setPhoneNumber(new SalesIQVisitorProfile.PhoneNumber(code != null ? code : "", number != null ? number : ""));
            }
        }
        Map<String, String> customInfo = MobilistenCorePlugin.getMapOrNull(call.argument("customInfo"));   // No I18N
        if (customInfo != null) {
            profile.setCustomInfo(customInfo);
        }
        Map<String, Object> locationMap = MobilistenCorePlugin.getMapOrNull(call.argument("location"));   // No I18N
        if (locationMap != null) {
            SIQVisitorLocation location = new SIQVisitorLocation();
            if (locationMap.get("latitude") != null) {
                location.setLatitude(LiveChatUtil.getDouble(locationMap.get("latitude")));   // No I18N
            }
            if (locationMap.get("longitude") != null) {
                location.setLongitude(LiveChatUtil.getDouble(locationMap.get("longitude")));   // No I18N
            }
            location.setCity(getStringOrNull(locationMap.get("city")));   // No I18N
            location.setState(getStringOrNull(locationMap.get("state")));   // No I18N
            location.setCountry(getStringOrNull(locationMap.get("country")));   // No I18N
            location.setCountryCode(getStringOrNull(locationMap.get("countryCode")));   // No I18N
            location.setZipCode(getStringOrNull(locationMap.get("zipCode")));   // No I18N
            profile.setLocation(location);
        }
        ZohoSalesIQ.Visitor.updateProfile(profile);
    }

    private static @Nullable ZohoSalesIQ.Homepage.Widget getHomepageWidget(@Nullable String widget) {
        if (widget == null) return null;
        switch (widget) {
            case "chat":
                return ZohoSalesIQ.Homepage.Widget.CHAT;
            case "call":
                return ZohoSalesIQ.Homepage.Widget.CALL;
            case "articles":
                return ZohoSalesIQ.Homepage.Widget.ARTICLES;
            case "faqs":
                return ZohoSalesIQ.Homepage.Widget.FAQS;
            case "previousConversations":
                return ZohoSalesIQ.Homepage.Widget.PREVIOUS_CONVERSATIONS;
            case "imageCard":
                return ZohoSalesIQ.Homepage.Widget.IMAGE_CARD;
            case "videoCard":
                return ZohoSalesIQ.Homepage.Widget.VIDEO_CARD;
            default:
                return null;
        }
    }

    private static PresentOptions.ConversationsListFilter getConversationsListFilter(@Nullable String filter) {
        if ("ongoing".equals(filter)) {  // No I18N
            return PresentOptions.ConversationsListFilter.ONGOING;
        } else if ("ended".equals(filter)) {  // No I18N
            return PresentOptions.ConversationsListFilter.ENDED;
        }
        return PresentOptions.ConversationsListFilter.ALL;
    }

    private static PresentOptions.ConversationList getConversationList(@Nullable Map<String, Object> listMap) {
        String type = listMap != null ? getStringOrNull(listMap.get("type")) : null;    // No I18N
        PresentOptions.ConversationsListFilter filter = getConversationsListFilter(listMap != null ? getStringOrNull(listMap.get("filter")) : null);    // No I18N
        if ("chat".equals(type)) {  // No I18N
            return new PresentOptions.ConversationList.Chat(filter);
        } else if ("call".equals(type)) {  // No I18N
            return new PresentOptions.ConversationList.Call(filter);
        } else if ("none".equals(type)) {  // No I18N
            return PresentOptions.ConversationList.None;
        }
        return new PresentOptions.ConversationList.All(filter);
    }

    private static @Nullable PresentOptions.Screen.Conversation.SessionType getSessionType(@Nullable String sessionType) {
        if ("chat".equals(sessionType)) {  // No I18N
            return PresentOptions.Screen.Conversation.SessionType.CHAT;
        } else if ("call".equals(sessionType)) {  // No I18N
            return PresentOptions.Screen.Conversation.SessionType.CALL;
        }
        return null;
    }

    private static PresentOptions.Screen.Conversation.SessionBehavior getSessionBehavior(@Nullable Map<String, Object> behaviorMap) {
        if (behaviorMap == null) {
            return PresentOptions.Screen.Conversation.SessionBehavior.None.INSTANCE;
        }
        PresentOptions.Screen.Conversation.SessionType sessionType = getSessionType(getStringOrNull(behaviorMap.get("sessionType")));    // No I18N
        if (sessionType == null) {
            sessionType = PresentOptions.Screen.Conversation.SessionType.CHAT;
        }
        String type = getStringOrNull(behaviorMap.get("type"));    // No I18N
        if ("alwaysNew".equals(type)) {  // No I18N
            return new PresentOptions.Screen.Conversation.SessionBehavior.AlwaysNew(sessionType);
        } else if ("continueOrNew".equals(type)) {  // No I18N
            return new PresentOptions.Screen.Conversation.SessionBehavior.ContinueOrNew(sessionType);
        }
        return PresentOptions.Screen.Conversation.SessionBehavior.None.INSTANCE;
    }

    private static void presentScreen(@NonNull MethodCall call, @NonNull Result result) {
        Map<String, Object> screenMap = MobilistenCorePlugin.getMapOrNull(call.argument("screen"));   // No I18N
        boolean showHomepage = LiveChatUtil.getBoolean(call.argument("showHomepage"));   // No I18N
        if (screenMap == null) {
            // No screen provided: open the SDK's default UI (null present
            // options) and report the actual result from the present callback.
            ZohoSalesIQ.present(null, presentResult -> {
                if (presentResult.isSuccess()) {
                    result.success(true);
                } else {
                    SalesIQError salesIQError = presentResult.getError();
                    if (salesIQError != null) {
                        result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                    } else {
                        result.error(CHAT_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null);
                    }
                }
            });
            return;
        }
        PresentOptions.Screen screen;
        String screenType = getStringOrNull(screenMap.get("screenType"));    // No I18N
        if ("conversation".equals(screenType)) {  // No I18N
            String id = getStringOrNull(screenMap.get("id"));    // No I18N
            PresentOptions.ConversationList list = getConversationList(MobilistenCorePlugin.getMapOrNull(screenMap.get("list")));   // No I18N
            if (id != null && !id.isEmpty()) {
                PresentOptions.Screen.Conversation.SessionType sessionType = getSessionType(getStringOrNull(screenMap.get("sessionType")));    // No I18N
                if (sessionType == null) {
                    sessionType = PresentOptions.Screen.Conversation.SessionType.CHAT;
                }
                screen = new PresentOptions.Screen.Conversation(id, sessionType, list);
            } else {
                screen = new PresentOptions.Screen.Conversation(list, getSessionBehavior(MobilistenCorePlugin.getMapOrNull(screenMap.get("sessionBehavior"))));   // No I18N
            }
        } else if ("knowledgeBase".equals(screenType)) {  // No I18N
            PresentOptions.Screen.KnowledgeBase.ResourceType kbResourceType = PresentOptions.Screen.KnowledgeBase.ResourceType.ARTICLES;
            String kbType = getStringOrNull(screenMap.get("resourceType"));    // No I18N
            if ("faqs".equals(kbType)) {    // No I18N
                kbResourceType = PresentOptions.Screen.KnowledgeBase.ResourceType.FAQ;
            } else if ("both".equals(kbType)) {    // No I18N
                kbResourceType = PresentOptions.Screen.KnowledgeBase.ResourceType.BOTH;
            }
            screen = new PresentOptions.Screen.KnowledgeBase(kbResourceType, getStringOrNull(screenMap.get("id")));    // No I18N
        } else {
            result.error(UNKNOWN_SCREEN_TYPE_CODE, "Unknown screenType: " + screenType, null); // No I18N
            return;
        }
        final boolean[] canSubmitCallback = {true};
        ZohoSalesIQ.present(new PresentOptions(screen, showHomepage), presentResult -> {
            if (canSubmitCallback[0]) {
                canSubmitCallback[0] = false;
                if (presentResult.isSuccess()) {
                    result.success(true);
                } else {
                    SalesIQError salesIQError = presentResult.getError();
                    if (salesIQError != null) {
                        result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                    } else {
                        result.error(CHAT_OPERATION_FAILED_CODE, UNKNOWN_ERROR_MESSAGE, null); // No I18N
                    }
                }
            }
        });
    }

    private static @Nullable String getCommunicationMode(CommunicationMode mode) {
        switch (mode) {
            case CHAT: {
                return "chat";  // No I18N
            }
            case CALL: {
                return "call";  // No I18N
            }
            case CHAT_AND_CALL: {
                return "chatAndCall";   // No I18N
            }
            default:
                return null;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        conversationsChannel.setMethodCallHandler(null);
        visitorChannel.setMethodCallHandler(null);
        homepageChannel.setMethodCallHandler(null);
        trackingChannel.setMethodCallHandler(null);
        chatActionsChannel.setMethodCallHandler(null);
        helpCenterChannel.setMethodCallHandler(null);
        knowledgeBaseChannel.setMethodCallHandler(null);
        chatChannel.setMethodCallHandler(null);
        launcherChannel.setMethodCallHandler(null);
        notificationChannel.setMethodCallHandler(null);
        SalesIQProviders.unregister();
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.application = binding.getActivity().getApplication();
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    public static Map<String, Object> getChatMapObject(@androidx.annotation.Nullable VisitorChat chat, boolean isEventStream) {
        Map<String, Object> visitorMap = new HashMap<String, Object>();
        if (chat == null) {
            return visitorMap;
        }
        visitorMap.put("id", chat.getChatID());         // No I18N
        visitorMap.put("unreadCount", chat.getUnreadCount());         // No I18N
        visitorMap.put("isBotAttender", chat.isBotAttender());         // No I18N
        if (chat.getQuestion() != null) {
            visitorMap.put("question", chat.getQuestion());         // No I18N
        }
        if (chat.getDepartmentName() != null) {
            visitorMap.put("departmentName", chat.getDepartmentName());         // No I18N
        }
        if (chat.getChatStatus() != null) {
            visitorMap.put("status", chat.getChatStatus().toLowerCase());         // No I18N
        }
        Map<String, Object> lastMessageMap = new HashMap<String, Object>();
        VisitorChat.SalesIQMessage lastMessage = chat.getLastMessage();
        if (lastMessage != null) {
            if (lastMessage.getText() != null) {
                visitorMap.put("lastMessage", lastMessage.getText());         // No I18N
            }
            if (lastMessage.getSender() != null) {
                visitorMap.put("lastMessageSender", lastMessage.getSender());         // No I18N
            }
            if (lastMessage.getTime() != null && lastMessage.getTime() > 0) {
                if (isEventStream) {
                    visitorMap.put("lastMessageTime", LiveChatUtil.getString(lastMessage.getTime()));         // No I18N
                    lastMessageMap.put("time", LiveChatUtil.getString(lastMessage.getTime()));         // No I18N
                } else {
                    visitorMap.put("lastMessageTime", LiveChatUtil.getDouble(lastMessage.getTime()));
                    lastMessageMap.put("time", LiveChatUtil.getDouble(lastMessage.getTime()));
                }
            }
            lastMessageMap.put("sender", lastMessage.getSender());
            lastMessageMap.put("sender_id", lastMessage.getSenderId());
            lastMessageMap.put("text", lastMessage.getText());
            lastMessageMap.put("type", lastMessage.getType());
            lastMessageMap.put("is_read", lastMessage.isRead());
            lastMessageMap.put("sent_by_visitor", lastMessage.getSentByVisitor());
            if (lastMessage.getStatus() != null) {
                String status = null;
                switch (lastMessage.getStatus()) {
                    case Sending:
                        status = SENDING;
                        break;
                    case Uploading:
                        status = UPLOADING;
                        break;
                    case Sent:
                        status = SENT;
                        break;
                    case Failure:
                        status = FAILURE;
                        break;
                }
                lastMessageMap.put("status", status);
            }
            VisitorChat.SalesIQMessage.SalesIQFile salesIQFile = lastMessage.getFile();
            Map<String, Object> fileMap = new HashMap<String, Object>();
            if (salesIQFile != null) {
                fileMap.put("name", salesIQFile.getName());
                fileMap.put("content_type", salesIQFile.getContentType());
                fileMap.put("comment", salesIQFile.getComment());
                fileMap.put("size", salesIQFile.getSize());
                lastMessageMap.put("file", fileMap);
            }
            visitorMap.put("recentMessage", lastMessageMap);         // No I18N
        }
        if (chat.getAttenderName() != null) {
            visitorMap.put("attenderName", chat.getAttenderName());         // No I18N
        }
        if (chat.getAttenderId() != null) {
            visitorMap.put("attenderID", chat.getAttenderId());         // No I18N
        }
        if (chat.getAttenderEmail() != null) {
            visitorMap.put("attenderEmail", chat.getAttenderEmail());         // No I18N
        }
        if (chat.getFeedbackMessage() != null) {
            visitorMap.put("feedback", chat.getFeedbackMessage());         // No I18N
        }
        if (chat.getRating() != null) {
            visitorMap.put("rating", chat.getRating());         // No I18N
        }
        if (chat.getQueuePosition() > 0) {
            visitorMap.put("queuePosition", chat.getQueuePosition());         // No I18N
        }
        return visitorMap;
    }

    public static Map<String, Object> getChatMapObject(SalesIQConversation conversation, boolean isEventStream) {
        Map<String, Object> visitorMap = new HashMap<String, Object>();
        visitorMap.put("id", conversation.getId());         // No I18N
        if (conversation instanceof SalesIQConversation.Chat) {
            visitorMap.put("unreadCount", ((SalesIQConversation.Chat) conversation).getUnreadCount());         // No I18N
            visitorMap.put("isBotAttender", ((SalesIQConversation.Chat) conversation).isBotAttender());         // No I18N
            if (((SalesIQConversation.Chat) conversation).getStatus() != null) {
                visitorMap.put("status", ((SalesIQConversation.Chat) conversation).getStatus().name().toLowerCase());         // No I18N
            }

            Map<String, Object> lastMessageMap = new HashMap<String, Object>();
            SalesIQConversation.Chat.SalesIQMessage lastMessage = ((SalesIQConversation.Chat) conversation).getLastSalesIQMessage();
            if (lastMessage != null) {
                if (lastMessage.getText() != null) {
                    visitorMap.put("lastMessage", lastMessage.getText());         // No I18N
                }
                if (lastMessage.getSender() != null) {
                    visitorMap.put("lastMessageSender", lastMessage.getSender());         // No I18N
                }
                if (lastMessage.getTime() != null && lastMessage.getTime() > 0) {
                    if (isEventStream) {
                        visitorMap.put("lastMessageTime", LiveChatUtil.getString(lastMessage.getTime()));         // No I18N
                        lastMessageMap.put("time", LiveChatUtil.getString(lastMessage.getTime()));         // No I18N
                    } else {
                        visitorMap.put("lastMessageTime", LiveChatUtil.getDouble(lastMessage.getTime()));
                        lastMessageMap.put("time", LiveChatUtil.getDouble(lastMessage.getTime()));
                    }
                }
                lastMessageMap.put("sender", lastMessage.getSender());
                lastMessageMap.put("sender_id", lastMessage.getSenderId());
                lastMessageMap.put("text", lastMessage.getText());
                lastMessageMap.put("type", lastMessage.getType());
                lastMessageMap.put("is_read", lastMessage.isRead());
                lastMessageMap.put("sent_by_visitor", lastMessage.getSentByVisitor());
                if (lastMessage.getStatus() != null) {
                    String status = null;
                    switch (lastMessage.getStatus()) {
                        case Sending:
                            status = SENDING;
                            break;
                        case Uploading:
                            status = UPLOADING;
                            break;
                        case Sent:
                            status = SENT;
                            break;
                        case Failure:
                            status = FAILURE;
                            break;
                    }
                    lastMessageMap.put("status", status);
                }
                SalesIQConversation.Chat.SalesIQMessage.SalesIQFile salesIQFile = lastMessage.getFile();
                Map<String, Object> fileMap = new HashMap<String, Object>();
                if (salesIQFile != null) {
                    fileMap.put("name", salesIQFile.getName());
                    fileMap.put("content_type", salesIQFile.getContentType());
                    fileMap.put("comment", salesIQFile.getComment());
                    fileMap.put("size", salesIQFile.getSize());
                    lastMessageMap.put("file", fileMap);
                }
                visitorMap.put("recentMessage", lastMessageMap);         // No I18N
            }

            if (conversation.getFeedback() != null) {
                visitorMap.put("feedback", conversation.getFeedback());         // No I18N
            }
        }
        if (conversation.getQuestion() != null) {
            visitorMap.put("question", conversation.getQuestion());         // No I18N
        }
        if (conversation.getDepartmentName() != null) {
            visitorMap.put("departmentName", conversation.getDepartmentName());         // No I18N
        }

        if (conversation.getAttenderName() != null) {
            visitorMap.put("attenderName", conversation.getAttenderName());         // No I18N
        }
        if (conversation.getAttenderId() != null) {
            visitorMap.put("attenderID", conversation.getAttenderId());         // No I18N
        }
        if (conversation.getAttenderEmail() != null) {
            visitorMap.put("attenderEmail", conversation.getAttenderEmail());         // No I18N
        }
        if (conversation.getRating() != null) {
            visitorMap.put("rating", conversation.getRating());         // No I18N
        }
        if (conversation.getQueuePosition() > 0) {
            visitorMap.put("queuePosition", conversation.getQueuePosition());         // No I18N
        }
        return visitorMap;
    }

    /// Serializes a SalesIQConversation into a map matching the Dart
    /// SalesIQConversation.fromMap shape (camelCase keys + a `type` discriminator).
    /// Mirrors the calls plugin's conversation mapping; used by the modern
    /// conversation-returning chat-start APIs.
    @androidx.annotation.Nullable
    public static Map<String, Object> getConversationMapObject(@androidx.annotation.Nullable SalesIQConversation conversation) {
        return MobilistenCorePlugin.getConversationMap(conversation);
    }

    /// Serializes a VisitorChat (returned by ZohoSalesIQ.Chat.get) into a map
    /// matching the Dart SalesIQConversation.fromMap shape. Used by the modern
    /// getConversation API.
    @androidx.annotation.Nullable
    public static Map<String, Object> getConversationMapObject(@androidx.annotation.Nullable VisitorChat chat) {
        if (chat == null) {
            return null;
        }
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("type", "chat");         // No I18N
        map.put("id", chat.getChatID());         // No I18N
        map.put("unreadCount", chat.getUnreadCount());         // No I18N
        map.put("isBotAttender", chat.isBotAttender());         // No I18N
        if (chat.getChatStatus() != null) {
            map.put("status", chat.getChatStatus().toLowerCase());         // No I18N
        }
        if (chat.getQuestion() != null) {
            map.put("question", chat.getQuestion());         // No I18N
        }
        if (chat.getDepartmentName() != null) {
            map.put("departmentName", chat.getDepartmentName());         // No I18N
        }
        if (chat.getAttenderName() != null) {
            map.put("attenderName", chat.getAttenderName());         // No I18N
        }
        if (chat.getAttenderId() != null) {
            map.put("attenderId", chat.getAttenderId());         // No I18N
        }
        if (chat.getAttenderEmail() != null) {
            map.put("attenderEmail", chat.getAttenderEmail());         // No I18N
        }
        if (chat.getFeedbackMessage() != null) {
            map.put("feedback", chat.getFeedbackMessage());         // No I18N
        }
        if (chat.getRating() != null) {
            map.put("rating", chat.getRating());         // No I18N
        }
        if (chat.getQueuePosition() > 0) {
            map.put("queuePosition", chat.getQueuePosition());         // No I18N
        }
        VisitorChat.SalesIQMessage lastMessage = chat.getLastMessage();
        if (lastMessage != null) {
            Map<String, Object> messageMap = new HashMap<String, Object>();
            messageMap.put("sender", lastMessage.getSender());         // No I18N
            messageMap.put("senderId", lastMessage.getSenderId());         // No I18N
            messageMap.put("text", lastMessage.getText());         // No I18N
            messageMap.put("type", lastMessage.getType());         // No I18N
            messageMap.put("isRead", lastMessage.isRead());         // No I18N
            messageMap.put("sentByVisitor", lastMessage.getSentByVisitor());         // No I18N
            if (lastMessage.getTime() != null && lastMessage.getTime() > 0) {
                messageMap.put("time", LiveChatUtil.getDouble(lastMessage.getTime()));         // No I18N
            }
            if (lastMessage.getStatus() != null) {
                String status = null;
                switch (lastMessage.getStatus()) {
                    case Sending:
                        status = SENDING;
                        break;
                    case Uploading:
                        status = UPLOADING;
                        break;
                    case Sent:
                        status = SENT;
                        break;
                    case Failure:
                        status = FAILURE;
                        break;
                }
                messageMap.put("status", status);         // No I18N
            }
            VisitorChat.SalesIQMessage.SalesIQFile salesIQFile = lastMessage.getFile();
            if (salesIQFile != null) {
                Map<String, Object> fileMap = new HashMap<String, Object>();
                fileMap.put("name", salesIQFile.getName());         // No I18N
                fileMap.put("contentType", salesIQFile.getContentType());         // No I18N
                fileMap.put("comment", salesIQFile.getComment());         // No I18N
                fileMap.put("size", salesIQFile.getSize());         // No I18N
                messageMap.put("file", fileMap);         // No I18N
            }
            map.put("lastSalesIQMessage", messageMap);         // No I18N
        }
        return map;
    }

    public Map<String, Object> getDepartmentMapObject(SIQDepartment department) {
        Map<String, Object> departmentMap = new HashMap<>();
        departmentMap.put("id", department.id);         // No I18N
        departmentMap.put("name", department.name);         // No I18N
        departmentMap.put("available", department.available);         // No I18N
        return departmentMap;
    }

    public static Map<String, Object> getVisitorInfoObject(SIQVisitor siqVisitor) {
        Map<String, Object> infoMap = new HashMap<String, Object>();
        if (siqVisitor.getName() != null) {
            infoMap.put("name", siqVisitor.getName());         // No I18N
        }
        if (siqVisitor.getEmail() != null) {
            infoMap.put("email", siqVisitor.getEmail());         // No I18N
        }
        if (siqVisitor.getPhone() != null) {
            infoMap.put("phone", siqVisitor.getPhone());         // No I18N
        }
        infoMap.put("numberOfChats", LiveChatUtil.getString(siqVisitor.getNumberOfChats()));         // No I18N
        if (siqVisitor.getCity() != null) {
            infoMap.put("city", siqVisitor.getCity());         // No I18N
        }
        if (siqVisitor.getIp() != null) {
            infoMap.put("ip", siqVisitor.getIp());         // No I18N
        }
        if (siqVisitor.getFirstVisitTime() != null) {
            Date firstVisitTime = siqVisitor.getFirstVisitTime();
            infoMap.put("firstVisitTime", LiveChatUtil.getString(firstVisitTime.getTime()));         // No I18N
        }
        if (siqVisitor.getLastVisitTime() != null) {
            Date lastVisitTime = siqVisitor.getLastVisitTime();
            infoMap.put("lastVisitTime", LiveChatUtil.getString(lastVisitTime.getTime()));         // No I18N
        }
        if (siqVisitor.getRegion() != null) {
            infoMap.put("region", siqVisitor.getRegion());         // No I18N
        }
        if (siqVisitor.getOs() != null) {
            infoMap.put("os", siqVisitor.getOs());         // No I18N
        }
        if (siqVisitor.getCountryCode() != null) {
            infoMap.put("countryCode", siqVisitor.getCountryCode());         // No I18N
        }
        if (siqVisitor.getBrowser() != null) {
            infoMap.put("browser", siqVisitor.getBrowser());         // No I18N
        }
        if (siqVisitor.getTotalTimeSpent() != null) {
            infoMap.put("totalTimeSpent", siqVisitor.getTotalTimeSpent());         // No I18N
        }
        infoMap.put("numberOfVisits", LiveChatUtil.getString(siqVisitor.getNumberOfVisits()));         // No I18N
        infoMap.put("noOfDaysVisited", LiveChatUtil.getString(siqVisitor.getNoOfDaysVisited()));         // No I18N
        if (siqVisitor.getState() != null) {
            infoMap.put("state", siqVisitor.getState());         // No I18N
        }
        if (siqVisitor.getSearchEngine() != null) {
            infoMap.put("searchEngine", siqVisitor.getSearchEngine());         // No I18N
        }
        if (siqVisitor.getSearchQuery() != null) {
            infoMap.put("searchQuery", siqVisitor.getSearchQuery());         // No I18N
        }
        return infoMap;
    }

    private Boolean isValidFilterName(String filterName) {
        for (ConversationType type : ConversationType.values()) {
            if (type.name().equalsIgnoreCase(filterName)) {
                return true;
            }
        }
        return false;
    }

    private ConversationType getFilterName(String filter) {
        switch (filter) {
            case TYPE_CONNECTED:
                return ConversationType.CONNECTED;
            case TYPE_WAITING:
                return ConversationType.WAITING;
            case TYPE_CLOSED:
                return ConversationType.CLOSED;
            case TYPE_ENDED:
                return ConversationType.ENDED;
            case TYPE_MISSED:
                return ConversationType.MISSED;
            default:
                return ConversationType.OPEN;
        }
    }

    public static void handleNotification(final Application application, final Map extras) {
        SharedPreferences sharedPreferences = application.getSharedPreferences("siq_session", 0);         // No I18N
        final String appKey = sharedPreferences.getString("salesiq_appkey", null);         // No I18N
        final String accessKey = sharedPreferences.getString("salesiq_accesskey", null);         // No I18N
        Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            public void run() {
                initSalesIQ(application, null, appKey, accessKey, null);
                ZohoSalesIQ.Notification.handle(application, extras);
            }
        });
    }

    public static void enablePush(String token, boolean testdevice) {
        fcmtoken = token;
        istestdevice = testdevice;
        if (token != null) {
            ZohoSalesIQ.Notification.enablePush(token, testdevice);
        }
    }

    private void setLauncherPropertiesForAndroid(final Map<String, Object> launcherPropertiesMap) {
        if (launcherPropertiesMap != null) {
            Object objectMode = launcherPropertiesMap.get("mode");
            int mode = LiveChatUtil.getInteger(objectMode != null ? objectMode : LauncherModes.FLOATING);
            LauncherProperties launcherProperties = new LauncherProperties(mode);
            if (launcherPropertiesMap.containsKey("yFromBottom")) {
                Object objectYFromBottom = launcherPropertiesMap.get("yFromBottom");
                int yFromBottom = (int) (objectYFromBottom != null ? objectYFromBottom : 0);
                launcherProperties.setYFromBottom(yFromBottom);
            }

            if (launcherPropertiesMap.containsKey("horizontal_direction")) {
                LauncherProperties.Horizontal horizontalDirection = null;
                if (Launcher.HORIZONTAL_LEFT.equals(
                        (String) launcherPropertiesMap.get("horizontal_direction")  // No I18N
                )) {
                    horizontalDirection = LauncherProperties.Horizontal.LEFT;
                } else if (Launcher.HORIZONTAL_RIGHT.equals(
                        (String) launcherPropertiesMap.get("horizontal_direction")  // No I18N
                )) {
                    horizontalDirection = LauncherProperties.Horizontal.RIGHT;
                }
                if (horizontalDirection != null) {
                    launcherProperties.setDirection(horizontalDirection);
                }
            }
            if (launcherPropertiesMap.containsKey("vertical_direction")) {
                LauncherProperties.Vertical verticalDirection = null;
                if (Launcher.VERTICAL_TOP.equals(
                        (String) launcherPropertiesMap.get("vertical_direction")    // No I18N
                )) {
                    verticalDirection = LauncherProperties.Vertical.TOP;
                } else if (Launcher.VERTICAL_BOTTOM.equals(
                        (String) launcherPropertiesMap.get("vertical_direction")    // No I18N
                )) {
                    verticalDirection = LauncherProperties.Vertical.BOTTOM;
                }
                if (verticalDirection != null) {
                    launcherProperties.setDirection(verticalDirection);
                }
            }

            if (application != null) {
                Drawable chatDrawable = getLauncherDrawable(launcherPropertiesMap.get("chat_icon"));
                Drawable callDrawable = getLauncherDrawable(launcherPropertiesMap.get("call_icon"));
                Drawable createDrawable = getLauncherDrawable(launcherPropertiesMap.get("create_icon"));
                Drawable closeDrawable = getLauncherDrawable(launcherPropertiesMap.get("close_icon"));
                if (chatDrawable != null || callDrawable != null || createDrawable != null || closeDrawable != null) {
                    launcherProperties.setIcons(chatDrawable, callDrawable, createDrawable, closeDrawable);
                }
            }
            ZohoSalesIQ.setLauncherProperties(launcherProperties);
        }
    }

    static boolean shouldOpenUrl = true;

    private void shouldOpenUrl(final boolean value) {
        shouldOpenUrl = value;
    }

    private int getStyleResourceId(String id) {
        int resourceId = 0;
        if (application != null) {
            resourceId = application.getResources().getIdentifier(
                    id, "style",   // No I18N
                    application.getPackageName());

        }
        return resourceId;
    }

    private Drawable getLauncherDrawable(Object nameObj) {
        if (!(nameObj instanceof String) || application == null) {
            return null;
        }
        int resourceId = getDrawableResourceId((String) nameObj);
        return resourceId > 0 ? application.getDrawable(resourceId) : null;
    }

    private int getDrawableResourceId(String drawableName) {
        int resourceId = 0;
        if (application != null) {
            resourceId = application.getResources().getIdentifier(
                    drawableName, "drawable",   // No I18N
                    application.getPackageName());

        }
        return resourceId;
    }

    private void setLoggerEnabled(final boolean value) {
        ZohoSalesIQ.Logger.setEnabled(value);
    }

    private void isLoggerEnabled(Result result) {
        result.success(ZohoSalesIQ.Logger.isEnabled());
    }

    private void sendEvent(final String event, final ArrayList objects) {
        switch (event) {
            case ReturnEvent.EVENT_OPEN_URL:
                final Application context = application;
                if (!shouldOpenUrl && objects.size() == 1) {
                    String url = (String) objects.get(0);
                    if (url != null) {
                        LiveChatUtil.openUri(context, Uri.parse(url));
                    }
                }
                break;
            case ReturnEvent.EVENT_COMPLETE_CHAT_ACTION:
                if (objects.size() > 0) {
                    String uuid = (String) objects.get(0);
                    boolean success = objects.size() <= 1 || objects.get(1) instanceof Boolean && (boolean) objects.get(1);
                    String message = objects.size() == 3 ? (String) objects.get(2) : null;
                    if (uuid != null && !uuid.isEmpty()) {
                        SalesIQCustomActionListener listener = ACTIONS_LIST.get(uuid);
                        if (listener != null) {
                            if (message != null && !message.isEmpty()) {
                                if (success) {
                                    listener.onSuccess(message);
                                } else {
                                    listener.onFailure(message);
                                }
                            } else {
                                if (success) {
                                    listener.onSuccess();
                                } else {
                                    listener.onFailure();
                                }
                            }
                        }
                        if (ACTIONS_LIST != null) {
                            ACTIONS_LIST.remove(uuid);
                        }
                    }
                }
            case ReturnEvent.EVENT_VISITOR_REGISTRATION_FAILURE: {
                if (objects.size() > 0) {
                    Object auth = objects.get(0);
                    if (auth instanceof HashMap) {
                        HashMap<String, Object> authMap = MobilistenCorePlugin.getHashmapOrNull(auth);
                        if (authMap == null) {
                            return;
                        }
                        handleVisitorRegistrationFailure(authMap);
                    }
                }
            }
            break;
        }
    }

    public static class SalesIQListeners implements SalesIQListener, SalesIQChatListener, SalesIQKnowledgeBaseListener, SalesIQActionListener, NotificationListener {
        @Override
        public void handleSupportOpen() {
            Map<String, String> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.supportOpened);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleSupportClose() {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.supportClosed);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleOperatorsOnline() {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.operatorsOnline);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleOperatorsOffline() {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.operatorsOffline);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleIPBlock() {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.visitorIPBlocked);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleTrigger(String triggerName, SIQVisitor siqVisitor) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> mapObject = getVisitorInfoObject(siqVisitor);
            eventMap.put("eventName", SIQEvent.customTrigger);
            eventMap.put("triggerName", triggerName);
            eventMap.put("visitorInformation", mapObject);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleBotTrigger() {
            Map<String, Object> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.botTrigger);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleCustomLauncherVisibility(boolean visible) {
            SalesIQListener.super.handleCustomLauncherVisibility(visible);
            Map<String, Object> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.customLauncherVisibility);
            eventMap.put("visible", visible);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
            if (launcherEventSink != null) {
                Map<String, Object> launcherEventMap = new HashMap<>();
                launcherEventMap.put("eventName", SIQEvent.customLauncherVisibility);
                launcherEventMap.put("visible", visible);
                launcherEventSink.success(launcherEventMap);
            }
        }

        @Nullable
        @Override
        public SalesIQAuth onVisitorRegistrationFailed(@NonNull SalesIQError salesIQError) {
            Map<String, Object> eventMap = new HashMap<>(3);
            eventMap.put("eventName", SIQEvent.visitorRegistrationFailure);
            eventMap.put("code", salesIQError.getCode());
            eventMap.put("message", salesIQError.getMessage());
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
            return null;
        }

        @Override
        public void handleChatViewOpen(String chatID) {
            Map<String, Object> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.chatViewOpened);
            eventMap.put("chatID", chatID);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatViewClose(String chatID) {
            Map<String, Object> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.chatViewClosed);
            eventMap.put("chatID", chatID);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatOpened(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatOpened);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatClosed(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatClosed);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatAttended(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatAttended);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatMissed(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatMissed);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatReOpened(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatReopened);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleRating(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.ratingReceived);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleFeedback(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.feedbackReceived);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleQueuePositionChange(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatQueuePositionChange);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public boolean handleUri(Uri uri, VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.handleURL);
            eventMap.put("chat", chatMapObject);
            eventMap.put("url", uri.toString());
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
            return shouldOpenUrl;
        }

        @Override
        public void onChatExpired(@Nullable VisitorChat chat) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(chat, true);
            eventMap.put("eventName", SIQEvent.chatExpired);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void onError(@Nullable VisitorChat chat, @Nullable ChatError error) {
            Map<String, Object> eventMap = new HashMap<>();
            Map<String, Object> chatMapObject = getChatMapObject(chat, true);
            eventMap.put("eventName", SIQEvent.chatError);
            eventMap.put("chat", chatMapObject);
            eventMap.put("error", getChatErrorObject(error));
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        private Map<String, Object> getChatErrorObject(@Nullable ChatError error) {
            Map<String, Object> errorMap = new HashMap<>();
            if (error != null) {
                errorMap.put("code", error.getCode());
                errorMap.put("message", error.getMessage());
            }

            String type = null;
            if (error instanceof ChatError.CreationFailed) {
                type = "creationFailed";    //No I18N
            } else if (error instanceof ChatError.MessagesSyncFailed) {
                type = "messagesSyncFailed";    //No I18N
            } else if (error instanceof ChatError.FormSyncFailed) {
                type = "formSyncFailed";    //No I18N
            } else if (error instanceof ChatError.TriggerTimedOut) {
                type = "triggerTimedOut";    //No I18N
            } else if (error instanceof ChatError.SocketConnectionFailedOnCreatingNewConversation) {
                type = "socketConnectionFailedOnCreatingNewConversation";    //No I18N
            } else if (error instanceof ChatError.TriggerFailed) {
                type = "triggerFailed";    //No I18N
            }
            if (type != null) {
                errorMap.put("type", type); // No I18N
            }
            return errorMap;
        }

        @Override
        public void handleCustomAction(SalesIQCustomAction salesIQCustomAction, SalesIQCustomActionListener salesIQCustomActionListener) {
            UUID uuid = UUID.randomUUID();

            final Map<String, Object> actionDetailsMap = new HashMap<>();
            actionDetailsMap.put("actionUUID", uuid.toString());         // No I18N
            actionDetailsMap.put("elementID", salesIQCustomAction.elementID);         // No I18N
            actionDetailsMap.put("label", salesIQCustomAction.label);         // No I18N
            actionDetailsMap.put("name", salesIQCustomAction.name);         // No I18N
            actionDetailsMap.put("clientActionName", salesIQCustomAction.clientActionName);         // No I18N

            ACTIONS_LIST.put(uuid.toString(), salesIQCustomActionListener);

            Map<String, Object> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.performChatAction);
            eventMap.put("chatAction", actionDetailsMap);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void onBadgeChange(int unreadCount) {
            Map<String, Object> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.chatUnreadCountChanged);     // No I18N
            eventMap.put("unreadCount", unreadCount);       // No I18N
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void onClick(@Nullable Context context, @NonNull SalesIQNotificationPayload payload) {
            Map<String, Object> eventMap = new HashMap<>();
            eventMap.put("eventName", SIQEvent.notificationClicked);     // No I18N
            eventMap.put("payload", Notification.getPayloadMap(payload));       // No I18N
            Notification.sendNotificationEvent(eventMap);
            if (SalesIQActivitiesManager.getInstance().isActivityStackEmpty(true)) {
                Intent intent = null;
                if (context != null) {
                    intent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                } else if (application != null) {
                    context = application;
                    intent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                    if (intent != null) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    }
                }
                if (intent != null) {
                    context.startActivity(intent);
                }
            }
        }

        @Override
        public void handleResourceOpened(@NonNull ZohoSalesIQ.ResourceType resourceType, @Nullable Resource resource) {
            if (resource != null) {
                Map<String, Object> eventMap = new HashMap<>();
                eventMap = addResourceType(eventMap, resourceType);
                eventMap.put("eventName", KnowledgeBaseEvent.resourceOpened);       // No I18N
                eventMap.put("resource", getMap(resource));       // No I18N
                if (knowledgeBaseEventSink != null) {
                    knowledgeBaseEventSink.success(eventMap);
                }
            }
        }

        @Override
        public void handleResourceClosed(@NonNull ZohoSalesIQ.ResourceType resourceType, @Nullable Resource resource) {
            if (resource != null) {
                Map<String, Object> eventMap = new HashMap<>();
                eventMap = addResourceType(eventMap, resourceType);
                eventMap.put("eventName", KnowledgeBaseEvent.resourceClosed);       // No I18N
                eventMap.put("resource", getMap(resource));       // No I18N
                if (knowledgeBaseEventSink != null) {
                    knowledgeBaseEventSink.success(eventMap);
                }
            }
        }

        @Override
        public void handleResourceLiked(@NonNull ZohoSalesIQ.ResourceType resourceType, @Nullable Resource resource) {
            if (resource != null) {
                Map<String, Object> eventMap = new HashMap<>();
                eventMap = addResourceType(eventMap, resourceType);
                eventMap.put("eventName", KnowledgeBaseEvent.resourceLiked);        // No I18N
                eventMap.put("resource", getMap(resource));       // No I18N
                if (knowledgeBaseEventSink != null) {
                    knowledgeBaseEventSink.success(eventMap);
                }
            }
        }

        @Override
        public void handleResourceDisliked(@NonNull ZohoSalesIQ.ResourceType resourceType, @Nullable Resource resource) {
            if (resource != null) {
                Map<String, Object> eventMap = new HashMap<>();
                eventMap = addResourceType(eventMap, resourceType);
                eventMap.put("eventName", KnowledgeBaseEvent.resourceDisliked);     // No I18N
                eventMap.put("resource", getMap(resource));       // No I18N
                if (knowledgeBaseEventSink != null) {
                    knowledgeBaseEventSink.success(eventMap);
                }
            }
        }

        @Override
        public void onError(@NonNull ZohoSalesIQ.ResourceType type, @Nullable Resource resource, @NonNull KnowledgeBaseError error) {
            Map<String, Object> eventMap = new HashMap<>();
            eventMap = addResourceType(eventMap, type);
            eventMap.put("eventName", KnowledgeBaseEvent.resourceError);     // No I18N
            eventMap.put("resource", getMap(resource));       // No I18N
            eventMap.put("error", getKnowledgeBaseErrorObject(error));
            if (knowledgeBaseEventSink != null) {
                knowledgeBaseEventSink.success(eventMap);
            }
        }

        private Map<String, Object> getKnowledgeBaseErrorObject(@Nullable KnowledgeBaseError error) {
            Map<String, Object> errorMap = new HashMap<>();
            if (error != null) {
                errorMap.put("code", error.getCode());
                errorMap.put("message", error.getMessage());
            }
            String type = null;
            if (error instanceof KnowledgeBaseError.ArticleCategoriesSyncFailed) {
                type = "articleCategoriesSyncFailure";        // No I18N
            } else if (error instanceof KnowledgeBaseError.ArticlesSyncFailed) {
                type = "articlesSyncFailure";        // No I18N
            } else if (error instanceof KnowledgeBaseError.ArticlesSearchFailed) {
                type = "articlesSearchFailure";        // No I18N
            } else if (error instanceof KnowledgeBaseError.FaqCategoriesSyncFailed) {
                type = "faqCategoriesSyncFailure";        // No I18N
            } else if (error instanceof KnowledgeBaseError.FaqsSyncFailed) {
                type = "faqsSyncFailure";        // No I18N
            } else if (error instanceof KnowledgeBaseError.FaqsSearchFailed) {
                type = "faqsSearchFailure";        // No I18N
            }
            if (type != null) {
                errorMap.put("type", type);        // No I18N
            }
            return errorMap;
        }

        static Map<String, Object> addResourceType(Map<String, Object> map, ZohoSalesIQ.ResourceType resourceType) {
            switch (resourceType) {
                case Articles:
                    map.put("type", 0);        // No I18N
                    break;
                case FAQs:
                    map.put("type", 1);        // No I18N
                    break;
            }
            return map;
        }
    }

    static class KnowledgeBaseEvent {
        static String resourceOpened = "resourceOpened";          // No I18N
        static String resourceClosed = "resourceClosed";          // No I18N
        static String resourceLiked = "resourceLiked";        // No I18N
        static String resourceDisliked = "resourceDisliked";          // No I18N
        static String resourceError = "resourceError";          // No I18N
    }

    static class SIQEvent {
        static String supportOpened = "supportOpened";                                   // No I18N
        static String supportClosed = "supportClosed";                                   // No I18N
        static String operatorsOnline = "operatorsOnline";                                   // No I18N
        static String operatorsOffline = "operatorsOffline";                                   // No I18N
        static String visitorIPBlocked = "visitorIPBlocked";                                   // No I18N
        static String customTrigger = "customTrigger";                                   // No I18N
        static String botTrigger = "botTrigger";                                   // No I18N
        static String customLauncherVisibility = "customLauncherVisibility";                                   // No I18N
        static String chatViewOpened = "chatViewOpened";                                   // No I18N
        static String chatViewClosed = "chatViewClosed";                                   // No I18N
        static String chatOpened = "chatOpened";                                   // No I18N
        static String chatClosed = "chatClosed";                                   // No I18N
        static String chatAttended = "chatAttended";                                   // No I18N
        static String chatMissed = "chatMissed";                                   // No I18N
        static String feedbackReceived = "feedbackReceived";                                   // No I18N
        static String ratingReceived = "ratingReceived";                                   // No I18N
        static String performChatAction = "performChatAction";                                   // No I18N
        static String chatQueuePositionChange = "chatQueuePositionChange";                                   // No I18N
        static String chatReopened = "chatReopened";                                   // No I18N
        static String chatExpired = "chatExpired";    // No I18N
        static String chatUnreadCountChanged = "chatUnreadCountChanged";    // No I18N
        static String handleURL = "handleURL";    // No I18N
        static String chatError = "chatError";    // No I18N
        static String notificationClicked = "notificationClicked";    // No I18N
        static String visitorRegistrationFailure = "visitorRegistrationFailure";    // No I18N
    }
}
