package com.salesiq.demoapp

import io.flutter.app.FlutterApplication
import com.zoho.salesiq.mobilisten.calls.plugin.MobilistenCallsPlugin
import com.zohosalesiq.plugin.MobilistenPlugin

class MyApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        MobilistenPlugin.registerCallbacks(this)
        MobilistenCallsPlugin.registerCallbacks(this)
    }
}