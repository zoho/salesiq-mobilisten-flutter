package com.zohosalesiq.plugin;

import android.app.Activity;
import android.app.Application;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.reflect.TypeToken;
import com.zoho.commons.ChatComponent;
import com.zoho.commons.LauncherModes;
import com.zoho.commons.LauncherProperties;
import com.zoho.livechat.android.NotificationListener;
import com.zoho.livechat.android.SIQDepartment;
import com.zoho.livechat.android.SIQVisitor;
import com.zoho.livechat.android.SIQVisitorLocation;
import com.zoho.livechat.android.SalesIQCustomAction;
import com.zoho.livechat.android.VisitorChat;
import com.zoho.livechat.android.ZohoLiveChat;
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
import com.zoho.livechat.android.modules.knowledgebase.ui.entities.Resource;
import com.zoho.livechat.android.modules.knowledgebase.ui.entities.ResourceCategory;
import com.zoho.livechat.android.modules.knowledgebase.ui.entities.ResourceDepartment;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.OpenResourceListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourceCategoryListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourceDepartmentsListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourceListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.ResourcesListener;
import com.zoho.livechat.android.modules.knowledgebase.ui.listeners.SalesIQKnowledgeBaseListener;
import com.zoho.livechat.android.operation.SalesIQApplicationManager;
import com.zoho.livechat.android.utils.LiveChatUtil;
import com.zoho.salesiqembed.ZohoSalesIQ;
import com.zoho.salesiqembed.ktx.GsonExtensionsKt;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.lang.reflect.Type;
import java.util.ArrayList;
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

    private MethodChannel channel, knowledgeBaseChannel;
    private EventChannel eventChannel, chatEventChannel, faqEventChannel;
    private Application application;
    private Activity activity;

    private static String fcmtoken = null;
    private static Boolean istestdevice = true;

    EventChannel.EventSink eventSink, chatEventSink, faqEventSink;
    static EventChannel.EventSink knowledgeBaseEventSink;
    private static final String MOBILISTEN_EVENT_CHANNEL = "mobilistenEventChannel";         // No I18N
    private static final String MOBILISTEN_CHAT_EVENT_CHANNEL = "mobilistenChatEventChannel";         // No I18N
    private static final String MOBILISTEN_FAQ_EVENT_CHANNEL = "mobilistenFAQEventChannel";         // No I18N

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

    private static Hashtable<String, SalesIQCustomActionListener> actionsList = new Hashtable<>();

    Handler handler;

    private static class Tab {
        static String CONVERSATIONS = "TAB_CONVERSATIONS";  // No I18N
        @Deprecated
        static String FAQ = "TAB_FAQ";  // No I18N
        static String KNOWLEDGE_BASE = "TAB_KNOWLEDGE_BASE";  // No I18N
    }

    private static class ReturnEvent {
        static final String EVENT_OPEN_URL = "OPEN_URL";  // No I18N
        static final String EVENT_COMPLETE_CHAT_ACTION = "COMPLETE_CHAT_ACTION";// No I18N
    }

    private static class Launcher {
        static final String HORIZONTAL_LEFT = "HORIZONTAL_LEFT";    // No I18N
        static final String HORIZONTAL_RIGHT = "HORIZONTAL_RIGHT";  // No I18N
        static final String VERTICAL_TOP = "VERTICAL_TOP";  // No I18N
        static final String VERTICAL_BOTTOM = "VERTICAL_BOTTOM";    // No I18N
    }

    static class KnowledgeBase {
        static final String ARTICLES = "Articles";  // No I18N
    }

    private final MethodCallHandler methodCallHandler = new MethodCallHandler() {
        @Override
        public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
            handleKnowledgeBaseMethodCalls(call, result);
        }
    };

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_mobilisten");         // No I18N
        channel.setMethodCallHandler(this);

        knowledgeBaseChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_knowledge_base");         // No I18N
        knowledgeBaseChannel.setMethodCallHandler(methodCallHandler);

        handler = new Handler(Looper.getMainLooper());

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_EVENT_CHANNEL);
        chatEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_CHAT_EVENT_CHANNEL);
        faqEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), MOBILISTEN_FAQ_EVENT_CHANNEL);
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
    }

    private static void handleKnowledgeBaseMethodCalls(MethodCall call, Result result) {
        Integer type = call.arguments != null ? call.argument("type") : null;   // No I18N
        ZohoSalesIQ.ResourceType resourceType = null;
        if (type != null && type == 0) {
            resourceType = ZohoSalesIQ.ResourceType.Articles;
        }
//        else {
//            // TODO: Need to implement FAQs in future.
//        }
        if (resourceType != null || Objects.equals(call.method, "getResourceDepartments")) {
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

//            case "isEnabled": {
//
//            }

                case "getSingleResource": {
//                LiveChatUtil.getBoolean(call.argument("should_fallback_to_default_language"))
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
                    ZohoSalesIQ.KnowledgeBase.getResources(resourceType, getStringOrNull(call.argument("departmentId")), getStringOrNull(call.argument("parentCategoryId")), getStringOrNull(call.argument("searchKey")), LiveChatUtil.getInteger(call.argument("page")), LiveChatUtil.getInteger(call.argument("limit")), new ResourcesListener() {  // No I18N
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

    private static @Nullable String getStringOrNull(Object object) {
        String value;
        if (object == null) {
            value = null;
        } else {
            value = (String) object;
        }
        return value;
    }

    static HashMap<String, Object> getMap(Object object) {
        Type mapType = new TypeToken<HashMap<String, Object>>() {}.getType();
        HashMap<String, Object> hashMap = GsonExtensionsKt.fromJsonSafe(DataModule.getGson(), DataModule.getGson().toJson(object), mapType);
        HashMap<String, Object> finalHashMap = new HashMap<>();
        for (Map.Entry<String, Object> entry : hashMap.entrySet()) {
            if (entry.getValue() instanceof Map) {
                finalHashMap.put(convertToCamelCase(entry.getKey()), getMap(entry.getValue()));
            } else {
                finalHashMap.put(convertToCamelCase(entry.getKey()), entry.getValue());
            }
        }
        return finalHashMap;
    }

    static String convertToCamelCase(String input) {
        StringBuilder camelCase = new StringBuilder(30);
        boolean capitalizeNext = false;

        for (char c : input.toCharArray()) {
            if (c == '_') {
                capitalizeNext = true;
            } else {
                camelCase.append(capitalizeNext ? Character.toUpperCase(c) : c);
                capitalizeNext = false;
            }
        }

        return camelCase.toString();
    }

    static List<HashMap<String, Object>> getMapList(Object objects) {
        ArrayList<HashMap<String, Object>> finalList = new ArrayList<>();
        if (objects != null) {
            List<Object> list = (List<Object>) objects;
            for (int index = 0; index < list.size(); index++) {
                finalList.add(getMap(list.get(index)));
            }
        }
        return finalList;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result rawResult) {
        final Result finalResult = rawResult;
        switch (call.method) {
            case "init":
                String appKey = LiveChatUtil.getString(call.argument("appKey"));         // No I18N
                String accessKey = LiveChatUtil.getString(call.argument("accessKey"));         // No I18N
                initSalesIQ(application, activity, appKey, accessKey, finalResult);
                ZohoSalesIQ.setPlatformName(SalesIQConstants.Platform.FLUTTER_ANDROID);
                SalesIQListeners listener = new SalesIQListeners();
                ZohoSalesIQ.setListener(listener);
                ZohoSalesIQ.Chat.setListener(listener);
                ZohoSalesIQ.KnowledgeBase.setListener(listener);
                ZohoSalesIQ.ChatActions.setListener(listener);
                ZohoSalesIQ.Notification.setListener(listener);
                break;

            case "showLauncher":
                ZohoSalesIQ.showLauncher(LiveChatUtil.getBoolean(call.arguments));
                handler = new Handler(Looper.getMainLooper());
                handler.post(new Runnable() {
                    public void run() {
                        if (activity != null && ZohoSalesIQ.getApplicationManager() != null) {
                            ZohoSalesIQ.getApplicationManager().setCurrentActivity(activity);
                            ZohoSalesIQ.getApplicationManager().refreshChatBubble();
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
                ZohoSalesIQ.Tracking.setCustomAction(LiveChatUtil.getString(call.argument("action_name")), LiveChatUtil.getBoolean(call.argument("should_open_chat_window")));  // No I18N
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
                handler = new Handler(Looper.getMainLooper());
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
                ZohoSalesIQ.KnowledgeBase.getResources(ZohoSalesIQ.ResourceType.Articles, null, categoryID, null, new ResourcesListener() {
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
                ZohoLiveChat.Chat.fetchAttenderImage(attenderID, fetchDefaultImage, new OperatorImageListener() {
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
                handler = new Handler(Looper.getMainLooper());
                handler.post(new Runnable() {
                    public void run() {
                        ZohoSalesIQ.ChatActions.setTimeout(timeout * 1000);
                    }
                });
                break;

            case "completeChatAction":
                final String actionID = LiveChatUtil.getString(call.arguments);
                handler = new Handler(Looper.getMainLooper());
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
                finalResult.success(ZohoLiveChat.Chat.isMultipleOpenRestricted());
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
            case "setThemeColorForiOS":
            case "writeLogForiOS":
            case "clearLogForiOS":
            case "setPathForiOS":
                break;
            default:
                finalResult.notImplemented();
                break;
        }
    }

    private static void initSalesIQ(final Application application, final Activity activity, final String appKey, final String accessKey, final Result result) {
        final boolean[] isCallBackInvoked = {false};
        if (application != null) {
            try {
                ZohoSalesIQ.init(application, appKey, accessKey, activity, null, new InitListener() {
                    @Override
                    public void onInitSuccess() {
                        if (activity != null && ZohoSalesIQ.getApplicationManager() != null) {
                            ZohoSalesIQ.getApplicationManager().setAppActivity(activity);
                            ZohoSalesIQ.getApplicationManager().setCurrentActivity(activity);
                            ZohoSalesIQ.getApplicationManager().refreshChatBubble();
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

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        knowledgeBaseChannel.setMethodCallHandler(null);
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

    public Map<String, Object> getChatMapObject(VisitorChat chat, boolean isEventStream) {
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

    public Map<String, Object> getVisitorInfoObject(SIQVisitor siqVisitor) {
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

    boolean shouldOpenUrl = true;

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
                break;
        }
    }

    public class SalesIQListeners implements SalesIQListener, SalesIQChatListener, SalesIQKnowledgeBaseListener, SalesIQActionListener, NotificationListener {
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
    }
}
