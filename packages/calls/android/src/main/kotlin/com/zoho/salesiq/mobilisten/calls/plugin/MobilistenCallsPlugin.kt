package com.zoho.salesiq.mobilisten.calls.plugin

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.content.Context
import android.util.Log
import android.view.View
import androidx.lifecycle.findViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.zoho.livechat.android.SIQDepartment
import com.zoho.livechat.android.modules.conversations.models.CommunicationMode
import com.zoho.livechat.android.modules.conversations.models.SalesIQConversation
import com.zoho.salesiq.core.modules.conversations.models.SalesIQConversationAttributes
import com.zoho.salesiq.mobilisten.calls.apis.ZohoSalesIQCalls
import com.zoho.salesiq.mobilisten.calls.apis.interfaces.SalesIQCallsListener
import com.zoho.salesiq.mobilisten.calls.plugin.activity.lifecycle.ActivityLifecycleOwner
import com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin
import com.zoho.salesiq.mobilisten.core.plugin.MobilistenCorePlugin.Companion.sendResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.HashMap

class MobilistenCallsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
    private lateinit var callChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var eventSink: EventSink? = null

    private var activity: Activity? = null
    private var context: Context? = null

    private val flutterSalesIQCallsListener = FlutterSalesIQCallsListener()

    private val callsMethodCallHandler =
        MethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            handleCallsMethodCalls(this, call, result)
        }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
        context = binding.applicationContext
        callChannel = MethodChannel(binding.binaryMessenger, "mobilisten_calls_api")
        callChannel.setMethodCallHandler(callsMethodCallHandler)

        eventChannel = EventChannel(binding.binaryMessenger, MOBILISTEN_CALLS_EVENT_CHANNEL)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        ZohoSalesIQCalls.addListener(flutterSalesIQCallsListener)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        callChannel.setMethodCallHandler(null)
        context = null

        ZohoSalesIQCalls.removeListener(flutterSalesIQCallsListener)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        lifecycleOwner?.currentActivity = binding.activity
        context = binding.activity.applicationContext
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        lifecycleOwner?.currentActivity = null
        context = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        lifecycleOwner?.currentActivity = binding.activity
        context = binding.activity.applicationContext
    }

    override fun onDetachedFromActivity() {
        activity = null
        lifecycleOwner?.currentActivity = null
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    }

    inner class FlutterSalesIQCallsListener : SalesIQCallsListener {
        override fun onCallStateChanged(callState: ZohoSalesIQCalls.SalesIQCallState) {
            super.onCallStateChanged(callState)
            val map = hashMapOf<String, Any>(
                "eventName" to "callStateChanged", "data" to callState.map
            )
            eventSink?.success(map)
        }

        override fun onQueuePositionChanged(conversationId: String, position: Int) {
            super.onQueuePositionChanged(conversationId, position)
            val map = hashMapOf<String, Any>(
                "eventName" to "queuePositionChanged", "data" to mapOf(
                    "conversationId" to conversationId, "position" to position
                )
            )
            eventSink?.success(map)
        }
    }

    companion object {
        private var isCallbacksRegistered = false

        @SuppressLint("StaticFieldLeak")
        var lifecycleOwner: ActivityLifecycleOwner? = null

        fun registerCallbacks(application: Application?) {
            if (!isCallbacksRegistered && application != null) {
                lifecycleOwner = ActivityLifecycleOwner(application)
                isCallbacksRegistered = true
            }
        }

        fun handleCallsMethodCalls(
            mobilistenCallsPlugin: MobilistenCallsPlugin,
            call: MethodCall,
            result: MethodChannel.Result,
        ) {
            when (call.method) {
                "currentCallId" -> {
                    result.success(currentCallId)
                }

                "currentCallState" -> {
                    result.success(currentCallStateMap)
                }

                "isEnabled" -> {
                    isEnabled(result)
                }

                "setTitle" -> {
                    setTitle(call)
                }

                "enterFullScreenMode" -> {
                    enterFullScreenMode()
                }

                "enterFloatingViewMode" -> {
                    enterFloatingViewMode()
                }

                "start" -> {
                    start(call, result)
                }

                "end" -> {
                    end(result)
                }

                "setAndroidReplyMessages" -> {
                    setReplyMessages(call)
                }

                "setVisibility" -> {
                    setVisibility(call, result)
                }

                "getStatusBarView" -> {
                    mobilistenCallsPlugin.flutterPluginBinding.platformViewRegistry.registerViewFactory(
                        "salesiq/mobilisten_calls_status_bar_view",
                        CallsViewFactory(mobilistenCallsPlugin)
                    )
                    val params = call.arguments as? Map<String, Any>
                    runCatching {
                        result.success(
                            mapOf(
                                "success" to true,
                                "viewType" to "salesiq/mobilisten_calls_status_bar_view",
                                "id" to View.generateViewId(),
                                "isDarkMode" to (params?.get("isDarkMode") ?: false)
                            )
                        )
                    }.onFailure {
                        result.error("VIEW_ERROR", "Failed to initialize view: ${it.message}", null)
                    }
                }

                "getCallConversations" -> {
                    getList(result)
                }

                "setCallKitIcon" -> {

                }

                else -> {

                }
            }
        }

        private val currentCallId: String? get() = ZohoSalesIQCalls.currentCallId

        private val currentCallStateMap: Map<String, Any?> get() = ZohoSalesIQCalls.currentState.map

        internal val ZohoSalesIQCalls.SalesIQCallState.map: Map<String, Any?>
            get() = mapOf(
                "isIncomingCall" to isIncomingCall,
                "status" to (if (status == ZohoSalesIQCalls.SalesIQCallStatus.ON_HOLD) {
                    ZohoSalesIQCalls.SalesIQCallStatus.CONNECTED
                } else {
                    status
                }).name.lowercase()
            )

        private fun isEnabled(result: MethodChannel.Result) {
            result.success(ZohoSalesIQCalls.isEnabled)
        }

        private fun setTitle(call: MethodCall) {
            ZohoSalesIQCalls.setTitle(
                call.argument("onlineTitle") as? String?, call.argument("offlineTitle") as? String?
            )
        }

        private fun enterFullScreenMode() {
            ZohoSalesIQCalls.enterFullScreenMode()
        }

        private fun enterFloatingViewMode() {
            ZohoSalesIQCalls.enterFloatingViewMode()
        }

        private fun start(call: MethodCall, methodChannelResult: MethodChannel.Result) {
            ZohoSalesIQCalls.start(
                call.argument("id") as? String,
                call.argument("displayActiveCall") as? Boolean != false,
                getConversationAttributes(call),
            ) { startResult ->
                startResult.sendResult(
                    methodChannelResult, startResult.data?.toCallConversationMap()
                )
            }
        }

        private fun SalesIQConversation?.toCallConversationMap(): Map<String, Any?> {
            return MobilistenCorePlugin.getMap(this).apply {
                if (this@toCallConversationMap is SalesIQConversation.Call) {
                    this["type"] = "Call"
                } else if (this@toCallConversationMap is SalesIQConversation.Chat) {
                    this["type"] = "Chat"
                    (this["lastSalesIQMessage"] as? HashMap<String, Any?>)?.put(
                        "senderId",
                        this@toCallConversationMap.lastSalesIQMessage?.senderId
                    )
                }
            }
        }

        private fun List<SalesIQConversation>?.toCallConversationListMap() =
            this?.map { conversation ->
                conversation.toCallConversationMap()
            }

        private fun getConversationAttributes(call: MethodCall): SalesIQConversationAttributes? {
            val attributesMap = call.argument("attributes") as? Map<String, Any>
            return attributesMap?.let { map ->
                SalesIQConversationAttributes.Builder().apply {
                    (attributesMap["name"] as? String?)?.let { setName(it) }
                    (attributesMap["additionalInfo"] as? String?)?.let { setAdditionalInfo(it) }
                    attributesMap["displayPicture"]?.let { setDisplayPicture(it) }
                    (attributesMap["departments"] as? List<Map<String, Any>>?)?.map { departmentMap ->
                        SIQDepartment(
                            id = departmentMap["id"] as? String,
                            name = departmentMap["name"] as? String,
                            communicationMode = departmentMap["communicationMode"]?.let {
                                CommunicationMode.values()[it as? Int ?: 0]
                            })
                    }?.let {
                        setDepartments(it)
                    }
                }.build()
            }
        }

        fun end(methodChannelResult: MethodChannel.Result) {
            ZohoSalesIQCalls.end { endResult ->
                Log.d("flutter", Log.getStackTraceString(Throwable()))
                endResult.sendResult(
                    methodChannelResult, endResult.data?.toCallConversationMap()
                )
            }
        }

        fun setReplyMessages(call: MethodCall) {
            ZohoSalesIQCalls.setReplyMessages(
                call.argument("messages") as? List<String> ?: emptyList()
            )
        }

        fun setVisibility(call: MethodCall, result: MethodChannel.Result) {
            val callComponent = getCallComponent(call)
            if (callComponent != null) {
                ZohoSalesIQCalls.setVisibility(
                    callComponent, call.argument("isVisible") as? Boolean ?: true
                )
                result.success(true)
            } else {
                result.error("INVALID_COMPONENT", "Invalid call component name", null)
            }
        }

        private fun getCallComponent(call: MethodCall): ZohoSalesIQCalls.CallComponent? {
            return when (call.argument("component") as? String?) {
                "preChatForm" -> {
                    ZohoSalesIQCalls.CallComponent.PreChatForm
                }

                "operatorName" -> {
                    ZohoSalesIQCalls.CallComponent.OperatorName
                }

                "operatorImage" -> {
                    ZohoSalesIQCalls.CallComponent.OperatorImage
                }

                "queuePosition" -> {
                    ZohoSalesIQCalls.CallComponent.QueuePosition
                }

                else -> {
                    null
                }
            }
        }

        private fun getList(methodChannelResult: MethodChannel.Result) {
            ZohoSalesIQCalls.getList { result ->
                result.sendResult(methodChannelResult, result.data.toCallConversationListMap())
            }
        }

        const val MOBILISTEN_CALLS_EVENT_CHANNEL = "mobilistenCallEvents"
    }

    class CallsViewFactory(private val mobilistenCallsPlugin: MobilistenCallsPlugin) :
        PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
            return CallsPlatformView(mobilistenCallsPlugin, viewId, args as? Map<String, Any?>?)
        }
    }

    class CallsPlatformView(
        private val mobilistenCallsPlugin: MobilistenCallsPlugin,
        private val viewId: Int,
        private val args: Map<String, Any?>?,
    ) : PlatformView {

        override fun getView(): View {
            val isDarkMode = args?.get("isDarkMode") as? Boolean? ?: false
            val statusBarView = ZohoSalesIQCalls.getStatusBarView(isDarkMode)?.apply {
                id = View.generateViewId()
            }
            if (mobilistenCallsPlugin.activity?.window?.decorView?.findViewTreeLifecycleOwner() == null) {
                mobilistenCallsPlugin.activity?.window?.decorView?.setViewTreeLifecycleOwner(
                    lifecycleOwner
                )
            }
            return if (statusBarView?.findViewTreeLifecycleOwner() != null) {
                statusBarView
            } else {
                if (statusBarView != null && lifecycleOwner != null) {
                    statusBarView.setViewTreeLifecycleOwner(lifecycleOwner)
                    statusBarView.setViewTreeSavedStateRegistryOwner(lifecycleOwner)
                    if (statusBarView.findViewTreeLifecycleOwner() != null) {
                        statusBarView
                    } else {
                        android.widget.TextView(mobilistenCallsPlugin.context).apply {
                            text = "Waiting for lifecycle owner..."
                        }
                    }
                } else {
                    // Fallback: Create a placeholder view if lifecycle owner is missing
                    android.widget.TextView(mobilistenCallsPlugin.context)
                }
            }
        }

        override fun dispose() {

        }
    }
}