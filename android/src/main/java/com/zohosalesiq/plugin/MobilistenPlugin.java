package com.zohosalesiq.plugin;

import android.net.Uri;
import android.app.Activity;
import android.app.Application;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;

import androidx.annotation.NonNull;

import com.zoho.commons.ChatComponent;
import com.zoho.commons.LauncherProperties;
import com.zoho.commons.LauncherModes;
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
import com.zoho.livechat.android.listeners.OpenArticleListener;
import com.zoho.livechat.android.listeners.OperatorImageListener;
import com.zoho.livechat.android.listeners.RegisterListener;
import com.zoho.livechat.android.listeners.SalesIQActionListener;
import com.zoho.livechat.android.listeners.SalesIQChatListener;
import com.zoho.livechat.android.listeners.SalesIQCustomActionListener;
import com.zoho.livechat.android.listeners.SalesIQFAQListener;
import com.zoho.livechat.android.listeners.SalesIQListener;
import com.zoho.livechat.android.models.SalesIQArticle;
import com.zoho.livechat.android.models.SalesIQArticleCategory;
import com.zoho.livechat.android.utils.LiveChatUtil;
import com.zoho.livechat.android.operation.SalesIQApplicationManager;
import com.zoho.salesiqembed.ZohoSalesIQ;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.content.res.AssetManager;
import android.content.res.AssetFileDescriptor;
import io.flutter.view.FlutterView;


public class MobilistenPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

    private MethodChannel channel;
    private EventChannel eventChannel, chatEventChannel, faqEventChannel;
    private Application application;
    private Activity activity;

    private static String fcmtoken = null;
    private static Boolean istestdevice = true;

    private EventChannel.EventSink eventSink, chatEventSink, faqEventSink;
    private static String mobilistenEventChannel = "mobilistenEventChannel";         // No I18N
    private static String mobilistenChatEventChannel = "mobilistenChatEventChannel";         // No I18N
    private static String mobilistenFAQEventChannel = "mobilistenFAQEventChannel";         // No I18N

    private static final String TYPE_OPEN = "open";         // No I18N
    private static final String TYPE_CONNECTED = "connected";         // No I18N
    private static final String TYPE_CLOSED = "closed";         // No I18N
    private static final String TYPE_ENDED = "ended";         // No I18N
    private static final String TYPE_MISSED = "missed";         // No I18N
    private static final String TYPE_WAITING = "waiting";         // No I18N

    private static final String INVALID_FILTER_CODE = "604";         // No I18N
    private static final String INVALID_FILTER_TYPE = "invalid filter type";         // No I18N

    private static Hashtable<String, SalesIQCustomActionListener> actionsList = new Hashtable<>();

    Handler handler;

    static class Tab {
        static String CONVERSATIONS = "TAB_CONVERSATIONS";  // No I18N
        static String FAQ = "TAB_FAQ";  // No I18N
    }

    static class ReturnEvent {
        private static final String EVENT_OPEN_URL = "OPEN_URL";  // No I18N
        private static final String EVENT_COMPLETE_CHAT_ACTION = "COMPLETE_CHAT_ACTION";// No I18N
    }

    class Launcher {
        static final String HORIZONTAL_LEFT = "HORIZONTAL_LEFT";    // No I18N
        static final String HORIZONTAL_RIGHT = "HORIZONTAL_RIGHT";  // No I18N
        static final String VERTICAL_TOP = "VERTICAL_TOP";  // No I18N
        static final String VERTICAL_BOTTOM = "VERTICAL_BOTTOM";    // No I18N
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "salesiq_mobilisten");         // No I18N
        channel.setMethodCallHandler(this);

        handler =  new Handler(Looper.getMainLooper());

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), mobilistenEventChannel);
        chatEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), mobilistenChatEventChannel);
        faqEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), mobilistenFAQEventChannel);

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

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result rawResult) {
        final Result finalResult = rawResult;
        switch (call.method) {
            case "init":
                String fcmToken = LiveChatUtil.getString(call.argument("fcmToken")); // No I18N
                this.fcmtoken = fcmToken;
                String appKey = LiveChatUtil.getString(call.argument("appKey"));         // No I18N
                String accessKey = LiveChatUtil.getString(call.argument("accessKey"));         // No I18N
                initSalesIQ(application, activity, appKey, accessKey, finalResult);
                ZohoSalesIQ.setPlatformName(SalesIQConstants.Platform.FLUTTER_ANDROID);
                SalesIQListeners listener = new SalesIQListeners();
                ZohoSalesIQ.setListener(listener);
                ZohoSalesIQ.Chat.setListener(listener);
                ZohoSalesIQ.FAQ.setListener(listener);
                ZohoSalesIQ.ChatActions.setListener(listener);
                ZohoSalesIQ.Notification.setListener(listener);
                break;

            case "showLauncher":
                ZohoSalesIQ.showLauncher(LiveChatUtil.getBoolean(call.arguments));
                handler = new Handler(Looper.getMainLooper());
                handler.post(new Runnable() {
                    public void run() {
                        if (activity != null) {
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
                ZohoSalesIQ.FAQ.setVisibility(LiveChatUtil.getBoolean(call.arguments));
                break;

            case "registerVisitor":
                ZohoSalesIQ.registerVisitor(LiveChatUtil.getString(call.arguments), new RegisterListener() {
                    @Override
                    public void onSuccess() {
                        finalResult.success("Success");    //No I18N
                    }

                    @Override
                    public void onFailure(int errorCode, String errorMessage) {
                        finalResult.error(LiveChatUtil.getString(errorCode), errorMessage, null);
                    }
                });
                break;

            case "unregisterVisitor":  //need to pass the current activity
                ZohoSalesIQ.unregisterVisitor(activity);  //need to pass the current activity
                break;

            case "setPageTitle":
                ZohoSalesIQ.Tracking.setPageTitle(LiveChatUtil.getString(call.arguments));
                break;

            case "performCustomAction":
                ZohoSalesIQ.Tracking.setCustomAction(LiveChatUtil.getString(call.arguments));
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
                handler.post(new Runnable(){
                    public void run(){
                        ZohoSalesIQ.Chat.getDepartments(new DepartmentListener() {
                            @Override
                            public void onSuccess(ArrayList<SIQDepartment> arrayList) {
                                if (arrayList != null){
                                    final List<Map<String, Object>> departmentList = new ArrayList<Map<String, Object>>();
                                    for (int i=0; i<arrayList.size(); i++){
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
                        for (int i=0; i< arrayList.size(); i++) {
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
                                if (arrayList != null){
                                    final List<Map<String, Object>> articleList = new ArrayList<Map<String, Object>>();
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
                                finalResult.error(""+code, message, null);
                            }
                        });
                    }
                });
                break;

            case "getArticlesWithCategoryID":
                String categoryID = LiveChatUtil.getString(call.arguments);
                ZohoSalesIQ.FAQ.getArticles(categoryID, new FAQListener() {
                    @Override
                    public void onSuccess(ArrayList<SalesIQArticle> arrayList) {
                        if (arrayList != null){
                            final List<Map<String, Object>> articleList = new ArrayList<Map<String, Object>>();
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
                        finalResult.error(""+code, message, null);
                    }
                });
                break;

            case "getArticleCategories":
                ZohoSalesIQ.FAQ.getCategories(new FAQCategoryListener() {
                    @Override
                    public void onSuccess(ArrayList<SalesIQArticleCategory> arrayList) {
                        final List<Map<String, Object>> categoryList = new ArrayList<Map<String, Object>>();
                        if (arrayList != null){
                            for (int i=0; i<arrayList.size(); i++) {
                                SalesIQArticleCategory category = arrayList.get(i);
                                Map<String, Object> categoryMap = new HashMap<String, Object>();
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
                        Bitmap bitmap = ((BitmapDrawable)drawable).getBitmap();

                        ByteArrayOutputStream baos = new ByteArrayOutputStream();
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos); //bm is the bitmap object
                        byte[] byteArrayImage = baos.toByteArray();

                        String encodedImage = Base64.encodeToString(byteArrayImage, Base64.DEFAULT);

                        encodedImage = encodedImage.replace("\n","");         // No I18N

                        finalResult.success(encodedImage);
                    }

                    @Override
                    public void onFailure(int errorCode, String errorMessage) {
                        finalResult.error(""+errorCode, errorMessage, null);
                    }
                });
                break;


            case "openArticle":
                ZohoLiveChat.FAQ.openArticle(LiveChatUtil.getString(call.arguments), new OpenArticleListener() {
                    @Override
                    public void onSuccess() {
                        finalResult.success("SUCCESS");                                      // No I18N
                    }

                    @Override
                    public void onFailure(int code, String message) {
                        finalResult.error(""+code, message, null);
                    }
                });
                break;

            case "registerChatAction":
                UUID uuid = UUID.randomUUID();
                ZohoLiveChat.ChatActions.register(LiveChatUtil.getString(call.arguments));
                break;

            case "unregisterChatAction":
                ZohoLiveChat.ChatActions.unregister(LiveChatUtil.getString(call.arguments));
                break;

            case "unregisterAllChatActions":
                ZohoLiveChat.ChatActions.unregisterAll();
                break;

            case "setChatActionTimeout":
                final long timeout =  LiveChatUtil.getLong(call.arguments);
                handler = new Handler(Looper.getMainLooper());
                handler.post(new Runnable() {
                    public void run() {
                        ZohoSalesIQ.ChatActions.setTimeout(timeout*1000);
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
                        if (listener != null){
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
                        if (listener != null){
                            if (state) {
                                if (message != null && message.length() > 0) {
                                    listener.onSuccess(message);
                                }
                                else{
                                    listener.onSuccess();
                                }
                            }
                            else{
                                if (message != null && message.length() > 0) {
                                    listener.onFailure(message);
                                }
                                else{
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
                ZohoSalesIQ.Notification.setIcon(getResourceId(LiveChatUtil.getString(call.arguments)));
                break;
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
            } catch (Exception e){
                LiveChatUtil.log(e);
            }
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
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

    public Map<String, Object> getChatMapObject(VisitorChat chat, boolean isEventStream){
        Map<String, Object> visitorMap = new HashMap<String, Object>();
        visitorMap.put("id", chat.getChatID());         // No I18N
        visitorMap.put("unreadCount", chat.getUnreadCount());         // No I18N
        visitorMap.put("isBotAttender", chat.isBotAttender());         // No I18N
        if (chat.getQuestion() != null){
            visitorMap.put("question", chat.getQuestion());         // No I18N
        }
        if (chat.getDepartmentName() != null){
            visitorMap.put("departmentName", chat.getDepartmentName());         // No I18N
        }
        if (chat.getChatStatus() != null){
            visitorMap.put("status", chat.getChatStatus().toLowerCase());         // No I18N
        }
        if (chat.getLastMessage() != null){
            visitorMap.put("lastMessage", chat.getLastMessage());         // No I18N
        }
        if (chat.getLastMessageSender() != null){
            visitorMap.put("lastMessageSender", chat.getLastMessageSender());         // No I18N
        }
        if (chat.getLastMessageTime() > 0){
            if (isEventStream) {
                visitorMap.put("lastMessageTime", LiveChatUtil.getString(chat.getLastMessageTime()));         // No I18N
            } else {
                visitorMap.put("lastMessageTime", LiveChatUtil.getDouble(chat.getLastMessageTime()));         // No I18N
            }
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
        infoMap.put("noOfDaysVisited",LiveChatUtil.getString(siqVisitor.getNoOfDaysVisited()));         // No I18N
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

    private Boolean isValidFilterName(String filterName){
        for (ConversationType type : ConversationType.values()) {
            if (type.name().equalsIgnoreCase(filterName)) {
                return true;
            }
        }
        return false;
    }

    private ConversationType getFilterName(String filter){
        switch (filter){
            case TYPE_CONNECTED : return ConversationType.CONNECTED;
            case TYPE_WAITING : return ConversationType.WAITING;
            case TYPE_OPEN : return ConversationType.OPEN;
            case TYPE_CLOSED : return ConversationType.CLOSED;
            case TYPE_ENDED : return ConversationType.ENDED;
            case TYPE_MISSED : return ConversationType.MISSED;
            default: return ConversationType.OPEN;
        }
    }

    public static void handleNotification(final Application application, final Map extras){
        SharedPreferences sharedPreferences = application.getSharedPreferences("siq_session", 0);         // No I18N
        final String appKey = sharedPreferences.getString("salesiq_appkey", null);         // No I18N
        final String accessKey = sharedPreferences.getString("salesiq_accesskey", null);         // No I18N
        Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            public void run() {
                initSalesIQ(application,  null, appKey, accessKey, null);
                ZohoSalesIQ.Notification.handle(application, extras);
            }
        });
    }

    public static void enablePush(String token, Boolean testdevice) {
        fcmtoken = token;
        istestdevice = testdevice;
    }
    
    private Drawable getDrawable(final String resourceName) {
        int resourceId = getResourceId(resourceName);
        Drawable drawable = null;
        if (resourceId > 0 && ZohoSalesIQ.getApplicationManager() != null && ZohoSalesIQ.getApplicationManager().getApplication() != null) {
            drawable = ZohoSalesIQ.getApplicationManager().getApplication().getDrawable(resourceId);
        }
        return drawable;
    }

    private void setLauncherPropertiesForAndroid(final Map<String, Object> launcherPropertiesMap) {        
        int mode = mode = LiveChatUtil.getInteger(launcherPropertiesMap.getOrDefault("mode", LauncherModes.FLOATING));  // No I18N
        LauncherProperties launcherProperties = new LauncherProperties(mode);
        int y = (int) launcherPropertiesMap.getOrDefault("y", -1);  // No I18N
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
            int resourceId = getResourceId((String) launcherPropertiesMap.get("icon"));
            Drawable drawable = ZohoSalesIQ.getApplicationManager().getApplication().getDrawable(resourceId);
            if (resourceId > 0 && drawable != null) {
                launcherProperties.setIcon(drawable);
            }
        }
        ZohoSalesIQ.setLauncherProperties(launcherProperties);        
    }

    boolean shouldOpenUrl = true;
    private void shouldOpenUrl(final boolean value) {
        shouldOpenUrl = value;
    }

    private void setTabOrder(final ArrayList<String> tabNames) {
        int minimumTabOrdersSize = Math.min(tabNames.size(), ZohoSalesIQ.Tab.values().length);
        ZohoSalesIQ.Tab[] tabOrder = new ZohoSalesIQ.Tab[minimumTabOrdersSize];
        int insertIndex = 0;
        for (int index = 0; index < minimumTabOrdersSize; index++) {
            String tabName = tabNames.get(index);
            if (Tab.CONVERSATIONS.equals(tabName)) {
                tabOrder[insertIndex++] = ZohoSalesIQ.Tab.Conversations;
            } else if (Tab.FAQ.equals(tabName)) {
                tabOrder[insertIndex++] = ZohoSalesIQ.Tab.FAQ;
            }
        }
        ZohoSalesIQ.setTabOrder(tabOrder);
    }

    private void printDebugLogsForAndroid(final Boolean value) {
        ZohoSalesIQ.printDebugLogs(value);
    }

    private void setNotificationIconForAndroid(final String drawableName) {
        int resourceId = getResourceId(drawableName);
        if (resourceId > 0) {
            ZohoSalesIQ.Notification.setIcon(resourceId);
        }
    }

    private int getResourceId(String drawableName) {
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

    public class SalesIQListeners implements SalesIQListener, SalesIQChatListener, SalesIQFAQListener, SalesIQActionListener, NotificationListener {
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
            eventMap.put("eventName",  SIQEvent.operatorsOffline);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleIPBlock() {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName",  SIQEvent.visitorIPBlocked);
            if (eventSink != null) {
                eventSink.success(eventMap);
            }
        }

        @Override
        public void handleTrigger(String triggerName, SIQVisitor siqVisitor) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            Map<String, Object> mapObject = getVisitorInfoObject(siqVisitor);
            eventMap.put("eventName",  SIQEvent.customTrigger);
            eventMap.put("triggerName",  triggerName);
            eventMap.put("visitorInformation", mapObject);
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
            eventMap.put("eventName",  SIQEvent.feedbackReceived);
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
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.chatUnreadCountChanged);
            eventMap.put("unreadCount", unreadCount);
            if (chatEventSink != null) {
                chatEventSink.success(eventMap);
            }
        }

        @Override
        public void handleArticleOpened(String articleID) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.articleOpened);
            eventMap.put("articleID", articleID);
            if (faqEventSink != null) {
                faqEventSink.success(eventMap);
            }
        }

        @Override
        public void handleArticleClosed(String articleID) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.articleClosed);
            eventMap.put("articleID", articleID);
            if (faqEventSink != null) {
                faqEventSink.success(eventMap);
            }
        }

        @Override
        public void handleArticleLiked(String articleID) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.articleLiked);
            eventMap.put("articleID", articleID);
            if (faqEventSink != null) {
                faqEventSink.success(eventMap);
            }
        }

        @Override
        public void handleArticleDisliked(String articleID) {
            Map<String, Object> eventMap = new HashMap<String, Object>();
            eventMap.put("eventName", SIQEvent.articleDisliked);
            eventMap.put("articleID", articleID);
            if (faqEventSink != null) {
                faqEventSink.success(eventMap);
            }
        }    
    }

    static class SIQEvent{
        static String supportOpened = "supportOpened";                                   // No I18N
        static String supportClosed = "supportClosed";                                   // No I18N
        static String operatorsOnline = "operatorsOnline";                                   // No I18N
        static String operatorsOffline = "operatorsOffline";                                   // No I18N
        static String visitorIPBlocked = "visitorIPBlocked";                                   // No I18N
        static String customTrigger = "customTrigger";                                   // No I18N
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
