package com.salesiq.demoapp

import com.zoho.salesiq.mobilisten.calls.plugin.MobilistenCallsPlugin
import com.zohosalesiq.plugin.MobilistenPlugin
import io.flutter.app.FlutterApplication

class MyApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        MobilistenPlugin.registerCallbacks(this)
        MobilistenCallsPlugin.registerCallbacks(this)
    }
}