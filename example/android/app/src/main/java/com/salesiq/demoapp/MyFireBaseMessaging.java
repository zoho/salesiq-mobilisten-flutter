package com.salesiq.demoapp;

import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.zohosalesiq.plugin.MobilistenPlugin;

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
        Log.d("Mobilisten","FCM push token: " + token);
        MobilistenPlugin.enablePush(token,true);
    }
}
