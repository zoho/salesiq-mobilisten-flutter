package com.salesiq.demoapp

import android.util.Log
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.app.FlutterApplication
import com.zoho.salesiq.mobilisten.calls.plugin.MobilistenCallsPlugin
import com.zohosalesiq.plugin.MobilistenPlugin

class MyApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        MobilistenPlugin.registerCallbacks(this)
        MobilistenCallsPlugin.registerCallbacks(this)

        // Fetch the current FCM token on every launch and register it with Mobilisten.
        // onNewToken() only fires when a token is (re)generated — on an existing install it won't
        // fire, so getToken() is the reliable way to obtain and log the current token.
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val token = task.result
                Log.d("Mobilisten", "FCM push token: $token")
                MobilistenPlugin.enablePush(token, true)
            } else {
                Log.e("Mobilisten", "Fetching FCM token failed", task.exception)
            }
        }
    }
}