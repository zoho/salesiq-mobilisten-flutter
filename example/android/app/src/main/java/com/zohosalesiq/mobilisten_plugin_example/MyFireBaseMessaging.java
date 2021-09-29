package com.zohosalesiq.mobilisten_plugin_example;

import com.zohosalesiq.plugin.MobilistenPlugin;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class MyFireBaseMessaging extends FirebaseMessagingService
{
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage)
    {
        Map extras = remoteMessage.getData();
        MobilistenPlugin.handleNotification(this.getApplication(),extras);
    }

    @Override
    public void onNewToken(String token){
//        MobilistenPlugin.enablePush(token,true);
    }
}
