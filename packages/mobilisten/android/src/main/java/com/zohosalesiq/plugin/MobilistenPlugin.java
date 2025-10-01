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
import com.zoho.livechat.android.ZohoLiveChat;
import com.zoho.livechat.android.config.DeviceConfig;
import com.zoho.livechat.android.constants.ConversationType;
import com.zoho.livechat.android.constants.SalesIQConstants;
import com.zoho.livechat.android.exception.InvalidEmailException;
import com.zoho.livechat.android.listeners.ConversationListener;
import com.zoho.livechat.android.listeners.DepartmentListener;
import com.zoho.livechat.android.listeners.FAQCategoryListener;
import com.zoho.livechat.android.listeners.FAQListener;
import com.zoho.livechat.android.listeners.InitListener;
import com.zoho.livechat.android.listeners.OperatorImageListener;
import com.zoho.livechat.android.listeners.RegisterListener;
import com.zoho.livechat.android.listeners.SalesIQActionListener;
import com.zoho.livechat.android.listeners.SalesIQChatListener;
import com.zoho.livechat.android.listeners.SalesIQCustomActionListener;
import com.zoho.livechat.android.listeners.SalesIQListener;
import com.zoho.livechat.android.listeners.UnRegisterListener;
import com.zoho.livechat.android.models.SalesIQArticle;
import com.zoho.livechat.android.models.SalesIQArticleCategory;
import com.zoho.livechat.android.modules.common.DataModule;
import com.zoho.livechat.android.modules.common.data.local.MobilistenEncryptedSharedPreferences;
import com.zoho.livechat.android.modules.common.domain.entities.DebugInfoData;
import com.zoho.livechat.android.modules.common.ui.LauncherUtil;
import com.zoho.livechat.android.modules.common.ui.LoggerUtil;
import com.zoho.livechat.android.modules.common.ui.lifecycle.SalesIQActivitiesManager;
import com.zoho.livechat.android.modules.common.ui.result.callbacks.ZohoSalesIQResultCallback;
import com.zoho.livechat.android.modules.common.ui.result.entities.SalesIQError;
import com.zoho.livechat.android.modules.common.ui.result.entities.SalesIQResult;
import com.zoho.livechat.android.modules.commonpreferences.data.local.CommonPreferencesLocalDataSource;
import com.zoho.livechat.android.modules.conversations.models.CommunicationMode;
import com.zoho.livechat.android.modules.conversations.models.SalesIQConversation;
import com.zoho.livechat.android.modules.deeplinking.models.SalesIQUriScheme;
import com.zoho.livechat.android.modules.jwt.domain.entities.SalesIQAuth;
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
import com.zoho.livechat.android.operation.SalesIQApplicationManager;
import com.zoho.livechat.android.utils.LiveChatUtil;
import com.zoho.salesiq.core.modules.conversations.models.SalesIQConversationAttributes;
import com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin;
import com.zoho.salesiqembed.ZohoSalesIQ;
import com.zoho.salesiqembed.models.SalesIQConfiguration;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.Objects;
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

    private MethodChannel channel, conversationsChannel, chatChannel, knowledgeBaseChannel, launcherChannel, notificationChannel;
    private EventChannel eventChannel, chatEventChannel, faqEventChannel, notificationEventChannel;
    static Application application;
    private Activity activity;

    private static String fcmtoken = null;
    private static Boolean istestdevice = true;

    static EventChannel.EventSink eventSink, chatEventSink, faqEventSink, notificationEventSink;
    static EventChannel.EventSink knowledgeBaseEventSink;
    private static final String MOBILISTEN_EVENT_CHANNEL = "mobilistenEventChannel";         // No I18N
    private static final String MOBILISTEN_CHAT_EVENT_CHANNEL = "mobilistenChatEventChannel";         // No I18N
    private static final String MOBILISTEN_FAQ_EVENT_CHANNEL = "mobilistenFAQEventChannel";         // No I18N
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

    private static Font customFont = null;

    private static Hashtable<String, SalesIQCustomActionListener> actionsList = new Hashtable<>();

    Handler handler = MobilistenCorePlugin.getHandler();

    private static class Font {
        public String regular;
        public String medium;
    }

    private static class Tab {
        static String CONVERSATIONS = "TAB_CONVERSATIONS";  // No I18N
        @Deprecated
        static String FAQ = "TAB_FAQ";  // No I18N
        static String KNOWLEDGE_BASE = "TAB_KNOWLEDGE_BASE";  // No I18N
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
            }
        }
    }

    static class KnowledgeBase {
        static final String ARTICLES = "Articles";  // No I18N
    }

    private final MethodCallHandler knowledgeBaseMethodCallHandler = (call, result) -> handleKnowledgeBaseMethodCalls(call, result);
    private final MethodCallHandler conversationsMethodCallHandler = (call, result) -> handleConversationsMethodCalls(call, result);
    private final MethodCallHandler chatMethodCallHandler = (call, result) -> handleChatMethodCalls(call, result);
    private final MethodCallHandler launcherMethodCallHandler = (call, result) -> Launcher.handleMethodCalls(call, result);
    private final MethodCallHandler notificationMethodCallHandler = (call, result) -> Notification.handleMethodCalls(call, result);

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

        launcherChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_launcher_module");  // No I18N
        launcherChannel.setMethodCallHandler(launcherMethodCallHandler);

        notificationChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiqNotificationModule");  // No I18N
        notificationChannel.setMethodCallHandler(notificationMethodCallHandler);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_EVENT_CHANNEL);
        chatEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_CHAT_EVENT_CHANNEL);
        faqEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_FAQ_EVENT_CHANNEL);
        notificationEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_NOTIFICATION_EVENT_CHANNEL);
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

        faqEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                faqEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                faqEventSink = null;
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
            Map resultMap = new HashMap();
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

                case "isSDKMessage":
                    boolean value;
                    try {
                        value = ZohoSalesIQ.Notification.isZohoSalesIQNotification((Map) call.arguments);
                    } catch (Exception e) {
                        value = false;
                    }
                    result.success(value);
                    break;

                case "processNotification":
                    ZohoSalesIQ.Notification.handle(application, (Map) call.arguments);
                    break;

                case "setNotificationActionSource":
                    ZohoSalesIQ.Notification.setActionSource(getActionSource(LiveChatUtil.getString(call.arguments)));
                    break;

                case "getNotificationPayload":
                    ZohoSalesIQ.Notification.getPayload((Map) call.arguments, salesIQResult -> {
                        if (salesIQResult.isSuccess()) {
                            result.success(getPayloadMap((SalesIQNotificationPayload) salesIQResult.getData()));
                        } else {
                            SalesIQError salesIQError = salesIQResult.getError();
                            if (salesIQError != null) {
                                result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                            } else {
                                result.error("100", "Unknown error", null); // No I18N
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
                chatComponent = ChatComponent.mediaCapture;
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

            case "fetchDepartments":
                ZohoSalesIQ.Conversation.getDepartments(new ZohoSalesIQResultCallback<List<SIQDepartment>>() {
                    @Override
                    public void onComplete(@NonNull SalesIQResult<List<SIQDepartment>> salesIQResult) {
                        List<SIQDepartment> departments = salesIQResult.getData();
                        if (departments == null) {
                            result.error("100", "Unknown error", null); // No I18N
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
                Map<String, Object> data = (Map<String, Object>) call.arguments;
                if ("endChatDetails".equals(data.get("type")) || "chat".equals(data.get("type"))) { // No I18N
                    Map<String, Object> payload = (Map<String, Object>) data.get("payload");
                    if (payload != null && payload.containsKey("chatId")) {
                        ZohoSalesIQ.Chat.open((String) payload.get("chatId"));    // No I18N
                    }
                }
                break;
            }

            case "hideQueueTime": {
                ZohoSalesIQ.Chat.hideQueueTime(LiveChatUtil.getBoolean(call.arguments));
                break;
            }

            case "setChatWaitingTime": {
                ZohoSalesIQ.Chat.setWaitingTime(LiveChatUtil.getInteger(call.arguments));
                break;
            }

            case "setChatTitle": {
                ZohoSalesIQ.Chat.setTitle(getStringOrNull(call.argument("onlineTitle")), getStringOrNull(call.argument("offlineTitle")));   // No I18N
                break;
            }

            case "startNewChat": {
                // TODO: Need to remove this fallback case if everything is fine from native end.
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
                                result.error("100", "Unknown error", null); // No I18N
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
                                result.error("100", "Unknown error", null); // No I18N
                            }
                        }
                    }
                });
                break;
            }

            case "startNewChatWithTrigger": {
                final boolean[] canSubmitCallback = {true};
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
                                result.error("100", "Unknown error", null); // No I18N
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
                            result.error("100", "Unknown error", null); // No I18N
                        }
                    }
                });
                break;
            }

            case "setChatComponentVisibility": {
                ChatComponent chatComponent = getChatComponent(LiveChatUtil.getString(call.argument("component_name")));    // No I18N
                if (chatComponent != null) {
                    ZohoSalesIQ.Chat.setVisibility(chatComponent, LiveChatUtil.getBoolean(call.argument("visible")));   // No I18N
                }
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
        }
//        else {
//            // TODO: Need to implement FAQs in future.
//        }
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
                    // TODO:    LiveChatUtil.getBoolean(call.argument("should_fallback_to_default_language"))
                    ZohoSalesIQ.KnowledgeBase.getSingleResource(resourceType, LiveChatUtil.getString(call.argument("id")), true, new ResourceListener() {   // No I18N
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
                    //LiveChatUtil.getBoolean(call.argument("includeChildCategoryResources"))
                    ZohoSalesIQ.KnowledgeBase.getResources(resourceType, getStringOrNull(call.argument("departmentId")), getStringOrNull(call.argument("parentCategoryId")), getStringOrNull(call.argument("searchKey")), LiveChatUtil.getInteger(call.argument("page")), LiveChatUtil.getInteger(call.argument("limit")), false, new ResourcesListener() {  // No I18N
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
            result.error("100", "Invalid resource type", null); // No I18N
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
            case "present": {
                present(getStringOrNull(call.argument("tab")), getStringOrNull(call.argument("id")), finalResult);  // No I18N
                break;
            }

            case "showLauncher":
                ZohoSalesIQ.showLauncher(LiveChatUtil.getBoolean(call.arguments));
                handler.post(new Runnable() {
                    public void run() {
                        if (activity != null && ZohoSalesIQ.getApplicationManager() != null) {
                            ZohoSalesIQ.getApplicationManager().setCurrentActivity(activity);
                            LauncherUtil.refreshLauncher();
                        }
                    }
                });
                break;

            case "setLanguage":
                ZohoSalesIQ.Chat.setLanguage(LiveChatUtil.getString(call.arguments));
                break;

            case "setDepartment":
                ZohoSalesIQ.Chat.setDepartment(LiveChatUtil.getString(call.arguments));
                break;

            case "setDepartments":
                ArrayList deptList = (ArrayList) call.arguments;
                ZohoSalesIQ.Chat.setDepartments(deptList);
                break;

            case "getCommunicationMode":
                finalResult.success(getCommunicationMode(ZohoSalesIQ.getCommunicationMode()));
                break;

            case "setQuestion":
                ZohoSalesIQ.Visitor.setQuestion(LiveChatUtil.getString(call.arguments));
                break;

            case "startChat":
                ZohoSalesIQ.Visitor.startChat(LiveChatUtil.getString(call.arguments));
                break;

            case "setConversationVisibility":
                ZohoSalesIQ.Conversation.setVisibility(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "setConversationListTitle":
                ZohoSalesIQ.Conversation.setTitle(LiveChatUtil.getString(call.arguments));
                break;

            case "setFAQVisibility":
                ZohoSalesIQ.KnowledgeBase.setVisibility(ZohoSalesIQ.ResourceType.Articles, LiveChatUtil.getBoolean(call.arguments));
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
                    }

                    @Override
                    public void onFailure(int code, String message) {
                        ZohoSalesIQ.Chat.setVisibility(ChatComponent.screenshot, false);
                    }
                });
                break;

            case "setPageTitle":
                ZohoSalesIQ.Tracking.setPageTitle(LiveChatUtil.getString(call.arguments));
                break;

            case "performCustomAction":
                boolean shouldOpenChatWindow = LiveChatUtil.getBoolean(call.argument("should_open_chat_window"));   // No I18N
                String customActionName = LiveChatUtil.getString(call.argument("action_name")); // No I18N
                if (shouldOpenChatWindow) {
                    ZohoSalesIQ.Tracking.setCustomAction(customActionName, true);
                } else {
                    ZohoSalesIQ.Visitor.performCustomAction(customActionName);
                }
                break;

            case "enableInAppNotification":
                ZohoSalesIQ.Notification.enableInApp();
                break;

            case "disableInAppNotification":
                ZohoSalesIQ.Notification.disableInApp();
                break;

            case "setOperatorEmail":
                try {
                    ZohoSalesIQ.Chat.setOperatorEmail(LiveChatUtil.getString(call.arguments));
                } catch (InvalidEmailException e) {
                    finalResult.error("10001", e.getMessage(), null);         // No I18N
                }
                break;

            case "show":
                ZohoSalesIQ.Chat.show();
                break;

            case "openChatWithID":
                ZohoSalesIQ.Chat.open(LiveChatUtil.getString(call.arguments));
                break;

            case "openNewChat":
                ZohoSalesIQ.Chat.openNewChat();
                break;

            case "showOfflineMessage":
                ZohoSalesIQ.Chat.showOfflineMessage(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "endChat":
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
                    Map<String, Object> visitorLocation = (Map<String, Object>) call.arguments;
                    SIQVisitorLocation siqVisitorLocation = new SIQVisitorLocation();

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
                    ZohoSalesIQ.Visitor.setLocation(siqVisitorLocation);
                }
                break;

            case "setChatTitle":
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

            case "getArticles":
                handler.post(new Runnable() {
                    public void run() {
                        ZohoSalesIQ.FAQ.getArticles(new FAQListener() {
                            @Override
                            public void onSuccess(ArrayList<SalesIQArticle> arrayList) {
                                if (arrayList != null) {
                                    final List<Map<String, Object>> articleList = new ArrayList<>();
                                    for (int i = 0; i < arrayList.size(); i++) {
                                        Map<String, Object> chatMapObject = getArticleMapObject(arrayList.get(i));
                                        articleList.add(chatMapObject);
                                    }
                                    handler.post(new Runnable() {
                                        @Override
                                        public void run() {
                                            finalResult.success(articleList);
                                        }
                                    });
                                }
                            }

                            @Override
                            public void onFailure(int code, String message) {
                                finalResult.error("" + code, message, null);
                            }
                        });
                    }
                });
                break;

            case "getArticlesWithCategoryID":
                String categoryID = LiveChatUtil.getString(call.arguments);
                ZohoSalesIQ.KnowledgeBase.getResources(ZohoSalesIQ.ResourceType.Articles, null, categoryID, null, false, new ResourcesListener() {
                    @Override
                    public void onSuccess(@NonNull List<Resource> resources, boolean moreDataAvailable) {
                        final List<Map<String, Object>> articleList = new ArrayList<>();
                        for (int i = 0; i < resources.size(); i++) {
                            Map<String, Object> chatMapObject = getArticleMapObject(resources.get(i));
                            articleList.add(chatMapObject);
                        }
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                finalResult.success(articleList);
                            }
                        });
                    }

                    @Override
                    public void onFailure(int code, @Nullable String message) {
                        finalResult.error("" + code, message, null);
                    }
                });
                break;

            case "getArticleCategories":
                ZohoSalesIQ.FAQ.getCategories(new FAQCategoryListener() {
                    @Override
                    public void onSuccess(ArrayList<SalesIQArticleCategory> arrayList) {
                        final List<Map<String, Object>> categoryList = new ArrayList<>();
                        if (arrayList != null) {
                            for (int i = 0; i < arrayList.size(); i++) {
                                SalesIQArticleCategory category = arrayList.get(i);
                                Map<String, Object> categoryMap = new HashMap<>();
                                categoryMap.put("id", category.getCategoryId());         // No I18N
                                categoryMap.put("name", category.getCategoryName());         // No I18N
                                categoryMap.put("articleCount", category.getCount());         // No I18N
                                categoryList.add(categoryMap);
                            }
                        }
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                finalResult.success(categoryList);
                            }
                        });
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


            case "openArticle":
                ZohoSalesIQ.KnowledgeBase.open(ZohoSalesIQ.ResourceType.Articles, LiveChatUtil.getString(call.arguments), new OpenResourceListener() {
                    @Override
                    public void onSuccess() {
                        finalResult.success("SUCCESS"); // No I18N
                    }

                    @Override
                    public void onFailure(int code, @Nullable String message) {
                        finalResult.error("" + code, message, null); // No I18N
                    }
                });
                break;

            case "registerChatAction":
                ZohoLiveChat.ChatActions.register(LiveChatUtil.getString(call.arguments));
                break;

            case "unregisterChatAction":
                ZohoLiveChat.ChatActions.unregister(LiveChatUtil.getString(call.arguments));
                break;

            case "unregisterAllChatActions":
                ZohoLiveChat.ChatActions.unregisterAll();
                break;

            case "setChatActionTimeout":
                final long timeout = LiveChatUtil.getLong(call.arguments);
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
                        listener = actionsList.get(actionID);
                        if (listener != null) {
                            listener.onSuccess();
                        }
                        if (actionsList != null) {
                            actionsList.remove(actionID);
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
                        SalesIQCustomActionListener listener = actionsList.get(actionId);
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
                        if (actionsList != null) {
                            actionsList.remove(actionId);
                        }
                    }
                });
                break;

            case "isMultipleOpenChatRestricted":
                finalResult.success(ZohoSalesIQ.Chat.isMultipleOpenRestricted());
                break;

            case "getChatUnreadCount":
                finalResult.success(ZohoLiveChat.Notification.getBadgeCount());
                break;
            case "setNotificationIconForAndroid":
                ZohoSalesIQ.Notification.setIcon(getDrawableResourceId(LiveChatUtil.getString(call.arguments)));
                break;
            case "setThemeForAndroid": {
                int resourceId = getStyleResourceId(LiveChatUtil.getString(call.arguments));
                if (resourceId > 0) {
                    ZohoSalesIQ.setTheme(resourceId);
                }
                break;
            }
            case "printDebugLogsForAndroid":
                ZohoSalesIQ.printDebugLogs(LiveChatUtil.getBoolean(call.arguments));
                break;
            case "setTabOrder":
                setTabOrder((ArrayList) call.arguments);
                break;
            case "shouldOpenUrl":
                shouldOpenUrl((Boolean) call.arguments);
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
                setLauncherPropertiesForAndroid((Map<String, Object>) call.arguments);
                break;
            case "syncThemeWithOSForAndroid":
                ZohoSalesIQ.syncThemeWithOS((Boolean) call.arguments);
                break;
            case "dismissUI":
                ZohoSalesIQ.dismissUI();
                break;
            case "setAndroidUriScheme":
                setUriScheme((Map<String, Object>) call.arguments);
                break;
            case "setThemeColorForiOS":
            case "writeLogForiOS":
            case "clearLogForiOS":
            case "setPathForiOS":
            case "registerLocalizationFileForiOS":
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
        List<String> hosts = hostsObject instanceof List ? (List<String>) hostsObject : null;
        List<Map<String, Object>> paths = pathsObject instanceof List ? (List<Map<String, Object>>) pathsObject : null;
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

    private static void handleVisitorRegistrationFailure(HashMap<String, Object> map) {
        if (map.containsKey("type")) {
            String type = (String) map.get("type");
            String userId = (String) map.get("user_id");
            if ("registered_visitor".equals(type)) {
                if (userId != null && !TextUtils.isEmpty(userId)) {
                    LiveChatUtil.log("MobilistenEncryptedSharedPreferences- re-registering visitor");   // No I18N
                    LiveChatUtil.registerVisitor(userId, new RegisterListener() {
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
                        if (activity != null && ZohoSalesIQ.getApplicationManager() != null) {
                            ZohoSalesIQ.getApplicationManager().setAppActivity(activity);
                            ZohoSalesIQ.getApplicationManager().setCurrentActivity(activity);
                            LauncherUtil.refreshLauncher();
                        }
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
                if (customFont != null) {
                    builder.setFont(Fonts.REGULAR, customFont.regular);
                    builder.setFont(Fonts.MEDIUM, customFont.medium);
                }
                ZohoSalesIQ.initialize(application, builder.build(), salesIQResult -> {
                    Handler handler = new Handler(Looper.getMainLooper());
                    if (salesIQResult.isSuccess()) {
                        if (activity != null && ZohoSalesIQ.getApplicationManager() != null) {
                            ZohoSalesIQ.getApplicationManager().setAppActivity(activity);
                            ZohoSalesIQ.getApplicationManager().setCurrentActivity(activity);
                            LauncherUtil.refreshLauncher();
                        }
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
                        String errorCode = error != null ? LiveChatUtil.getString(error.getCode()) : "1000"; // No I18N
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

    private static void present(@Nullable String tab, @Nullable String id, Result result) {
        final boolean[] canSubmitCallback = {true};
        ZohoSalesIQ.present(getTab(tab), id, presentResult -> {
            if (canSubmitCallback[0]) {
                canSubmitCallback[0] = false;
                if (presentResult.isSuccess()) {
                    result.success(true);
                } else {
                    SalesIQError salesIQError = presentResult.getError();
                    if (salesIQError != null) {
                        result.error(LiveChatUtil.getString(salesIQError.getCode()), salesIQError.getMessage(), null);
                    } else {
                        result.error("100", "Unknown error", null); // No I18N
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

    private static @Nullable ZohoSalesIQ.Tab getTab(@Nullable String tab) {
        ZohoSalesIQ.Tab tabType = null;
        if (Tab.CONVERSATIONS.equals(tab)) {
            tabType = ZohoSalesIQ.Tab.Conversations;
        } else if (Tab.KNOWLEDGE_BASE.equals(tab) || Tab.FAQ.equals(tab)) {
            tabType = ZohoSalesIQ.Tab.KnowledgeBase;
        }
        return tabType;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        conversationsChannel.setMethodCallHandler(null);
        knowledgeBaseChannel.setMethodCallHandler(null);
        chatChannel.setMethodCallHandler(null);
        launcherChannel.setMethodCallHandler(null);
        notificationChannel.setMethodCallHandler(null);
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

    public static Map<String, Object> getChatMapObject(VisitorChat chat, boolean isEventStream) {
        Map<String, Object> visitorMap = new HashMap<String, Object>();
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

    public Map<String, Object> getArticleMapObject(Resource article) {
        Map<String, Object> articleMap = new HashMap<>();
        articleMap.put("id", article.getId());         // No I18N
        articleMap.put("name", article.getTitle());         // No I18N
        if (article.getCategory() != null) {
            if (article.getCategory().getId() != null) {
                articleMap.put("categoryID", article.getCategory().getId());         // No I18N
            }
            if (article.getCategory().getId() != null) {
                articleMap.put("categoryName", article.getCategory().getName());         // No I18N
            }
        }
        if (article.getStats() != null) {
            articleMap.put("viewCount", article.getStats().getViewed());         // No I18N
            articleMap.put("likeCount", article.getStats().getLiked());         // No I18N
            articleMap.put("dislikeCount", article.getStats().getDisliked());         // No I18N
        }
        if (article.getDepartmentId() != null) {
            articleMap.put("departmentID", article.getDepartmentId());         // No I18N
        }
        articleMap.put("createdTime", LiveChatUtil.getDouble(article.getCreatedTime()));         // No I18N
        articleMap.put("modifiedTime", LiveChatUtil.getDouble(article.getModifiedTime()));         // No I18N
        return articleMap;
    }

    public Map<String, Object> getArticleMapObject(SalesIQArticle article) {
        Map<String, Object> articleMap = new HashMap<String, Object>();
        articleMap.put("id", article.getId());         // No I18N
        articleMap.put("name", article.getTitle());         // No I18N
        if (article.getCategoryId() != null) {
            articleMap.put("categoryID", article.getCategoryId());         // No I18N
        }
        if (article.getCategoryName() != null) {
            articleMap.put("categoryName", article.getCategoryName());         // No I18N
        }
        articleMap.put("viewCount", article.getViewed());         // No I18N
        articleMap.put("likeCount", article.getLiked());         // No I18N
        articleMap.put("dislikeCount", article.getDisliked());         // No I18N
        articleMap.put("departmentID", article.getDepartmentId());         // No I18N
        articleMap.put("createdTime", LiveChatUtil.getDouble(article.getCreatedTime()));         // No I18N
        articleMap.put("modifiedTime", LiveChatUtil.getDouble(article.getModifiedTime()));         // No I18N
        return articleMap;
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
            case TYPE_OPEN:
                return ConversationType.OPEN;
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

    public static void enablePush(String token, Boolean testdevice) {
        fcmtoken = token;
        istestdevice = testdevice;
    }

    private void setLauncherPropertiesForAndroid(final Map<String, Object> launcherPropertiesMap) {
        if (launcherPropertiesMap != null) {
            Object objectMode = launcherPropertiesMap.get("mode");
            int mode = LiveChatUtil.getInteger(objectMode != null ? objectMode : LauncherModes.FLOATING);
            LauncherProperties launcherProperties = new LauncherProperties(mode);
            Object objectY = launcherPropertiesMap.get("y");
            int y = (int) (objectY != null ? objectY : -1);
            if (y > -1) {
                launcherProperties.setY(y);
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
            if (launcherPropertiesMap.containsKey("icon") &&
                    ZohoSalesIQ.getApplicationManager() != null &&
                    ZohoSalesIQ.getApplicationManager().getApplication() != null
            ) {
                int resourceId = getDrawableResourceId((String) launcherPropertiesMap.get("icon"));
                Drawable drawable = ZohoSalesIQ.getApplicationManager().getApplication().getDrawable(resourceId);
                if (resourceId > 0 && drawable != null) {
                    launcherProperties.setIcon(drawable);
                }
            }
            ZohoSalesIQ.setLauncherProperties(launcherProperties);
        }
    }

    private static boolean shouldOpenUrl = true;

    private void shouldOpenUrl(final boolean value) {
        shouldOpenUrl = value;
    }

    private void setTabOrder(final ArrayList<String> tabNames) {
        int minimumTabOrdersSize = Math.min(tabNames.size(), (ZohoSalesIQ.Tab.values().length - 1)); // -1 is added for deprecated FAQ value
        ZohoSalesIQ.Tab[] tabOrder = new ZohoSalesIQ.Tab[minimumTabOrdersSize];
        int insertIndex = 0;
        for (int index = 0; index < minimumTabOrdersSize; index++) {
            String tabName = tabNames.get(index);
            if (Tab.CONVERSATIONS.equals(tabName)) {
                tabOrder[insertIndex++] = ZohoSalesIQ.Tab.Conversations;
            } else if (Tab.FAQ.equals(tabName) || Tab.KNOWLEDGE_BASE.equals(tabName)) {
                tabOrder[insertIndex++] = ZohoSalesIQ.Tab.KnowledgeBase;
            }
        }
        ZohoSalesIQ.setTabOrder(tabOrder);
    }

    private void printDebugLogsForAndroid(final Boolean value) {
        ZohoSalesIQ.printDebugLogs(value);
    }

    private int getStyleResourceId(String id) {
        SalesIQApplicationManager salesIQApplicationManager = ZohoSalesIQ.getApplicationManager();
        int resourceId = 0;
        if (salesIQApplicationManager != null) {
            resourceId = salesIQApplicationManager.getApplication().getResources().getIdentifier(
                    id, "style",   // No I18N
                    ZohoSalesIQ.getApplicationManager().getApplication().getPackageName());

        }
        return resourceId;
    }

    private int getDrawableResourceId(String drawableName) {
        SalesIQApplicationManager salesIQApplicationManager = ZohoSalesIQ.getApplicationManager();
        int resourceId = 0;
        if (salesIQApplicationManager != null) {
            resourceId = salesIQApplicationManager.getApplication().getResources().getIdentifier(
                    drawableName, "drawable",   // No I18N
                    ZohoSalesIQ.getApplicationManager().getApplication().getPackageName());

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
                        SalesIQCustomActionListener listener = actionsList.get(uuid);
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
                        if (actionsList != null) {
                            actionsList.remove(uuid);
                        }
                    }
                }
            case ReturnEvent.EVENT_VISITOR_REGISTRATION_FAILURE: {
                if (objects.size() > 0) {
                    Object auth = objects.get(0);
                    if (auth instanceof HashMap) {
                        handleVisitorRegistrationFailure((HashMap<String, Object>) auth);
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
            Map<String, Object> eventMap = new HashMap<String, Object>();
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
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.chatViewOpened);
            eventMap.put("chatID", chatID);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatViewClose(String chatID) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.chatViewClosed);
            eventMap.put("chatID", chatID);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatOpened(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatOpened);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatClosed(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatClosed);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatAttended(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatAttended);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatMissed(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatMissed);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleChatReOpened(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatReopened);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleRating(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.ratingReceived);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleFeedback(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.feedbackReceived);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleQueuePositionChange(VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> chatMapObject = getChatMapObject(visitorChat, true);
            eventMap.put("eventName", SIQEvent.chatQueuePositionChange);
            eventMap.put("chat", chatMapObject);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public boolean handleUri(Uri uri, VisitorChat visitorChat) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
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
        public void handleCustomAction(SalesIQCustomAction salesIQCustomAction, SalesIQCustomActionListener salesIQCustomActionListener) {
            UUID uuid = UUID.randomUUID();

            final Map<String, Object> actionDetailsMap = new HashMap<String, Object>();
            actionDetailsMap.put("actionUUID", uuid.toString());         // No I18N
            actionDetailsMap.put("elementID", salesIQCustomAction.elementID);         // No I18N
            actionDetailsMap.put("label", salesIQCustomAction.label);         // No I18N
            actionDetailsMap.put("name", salesIQCustomAction.name);         // No I18N
            actionDetailsMap.put("clientActionName", salesIQCustomAction.clientActionName);         // No I18N

            actionsList.put(uuid.toString(), salesIQCustomActionListener);

            Map<String, Object> eventMap = new HashMap<String, Object>();
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
                eventMap = new HashMap<String, Object>();
                eventMap.put("eventName", SIQEvent.articleOpened);
                eventMap.put("articleID", resource.getId());
                if (faqEventSink != null) {
                    faqEventSink.success(eventMap);
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
                eventMap = new HashMap<String, Object>();
                eventMap.put("eventName", SIQEvent.articleClosed);
                eventMap.put("articleID", resource.getId());
                if (faqEventSink != null) {
                    faqEventSink.success(eventMap);
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
                eventMap = new HashMap<String, Object>();
                eventMap.put("eventName", SIQEvent.articleLiked);
                eventMap.put("articleID", resource.getId());
                if (faqEventSink != null) {
                    faqEventSink.success(eventMap);
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
                eventMap = new HashMap<String, Object>();
                eventMap.put("eventName", SIQEvent.articleDisliked);
                eventMap.put("articleID", resource.getId());
                if (faqEventSink != null) {
                    faqEventSink.success(eventMap);
                }
            }
        }

        Map<String, Object> addResourceType(Map<String, Object> map, ZohoSalesIQ.ResourceType resourceType) {
            switch (resourceType) {
                case Articles:
                    map.put("type", 0);        // No I18N
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
        static String articleLiked = "articleLiked";                                   // No I18N
        static String articleDisliked = "articleDisliked";                                   // No I18N
        static String articleOpened = "articleOpened";                                   // No I18N
        static String articleClosed = "articleClosed";                                   // No I18N
        static String chatUnreadCountChanged = "chatUnreadCountChanged";    // No I18N
        static String handleURL = "handleURL";    // No I18N
        static String notificationClicked = "notificationClicked";    // No I18N
        static String visitorRegistrationFailure = "visitorRegistrationFailure";    // No I18N
    }
}
