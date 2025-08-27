package com.zoho.salesiq.mobilisten.core.plugin

import android.os.Handler
import android.os.Looper
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.zoho.livechat.android.SIQDepartment
import com.zoho.livechat.android.modules.common.ui.result.entities.SalesIQResult
import com.zoho.salesiq.core.modules.conversations.models.SalesIQConversationAttributes
import com.zoho.salesiq.mobilisten.core.enums.ResultType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.HashMap
import kotlin.collections.emptyList
import kotlin.collections.forEach
import kotlin.collections.hashMapOf
import kotlin.collections.map

class MobilistenCorePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }

    companion object {

        val gson by lazy { Gson() }

        @JvmStatic
        val handler by lazy { Handler(Looper.getMainLooper()) }

        @JvmStatic
        fun getStringOrNull(obj: Any?): String? {
            return if (obj == null) null else obj as String
        }

        @JvmStatic
        fun getString(obj: Any?): String {
            return if (obj == null) "" else obj as String
        }

        @JvmStatic
        fun getMap(any: Any?): HashMap<String, Any?> {
            val mapType = object : TypeToken<HashMap<String, Any?>>() {}.type
            val hashMap = runCatching {
                gson.fromJson<HashMap<String, Any?>>(gson.toJson(any), mapType)
            }.getOrNull()
            val finalHashMap = hashMapOf<String, Any?>()
            hashMap?.forEach {
                if (it.value is Map<*, *>) {
                    finalHashMap.put(
                        convertToCamelCase(it.key), getMap(it.value)
                    )
                } else {
                    finalHashMap.put(convertToCamelCase(it.key), it.value)
                }
            }
            return finalHashMap
        }

        @JvmStatic
        fun convertToCamelCase(input: String): String {
            val camelCase = StringBuilder()
            var capitalizeNext = false

            for (c in input) {
                if (c == '_') {
                    capitalizeNext = true
                } else {
                    camelCase.append(if (capitalizeNext) c.uppercaseChar() else c)
                    capitalizeNext = false
                }
            }

            return camelCase.toString()
        }

        @JvmStatic
        fun getMapList(obj: Any?): List<Map<String, Any?>> {
            val list = obj as? List<*> ?: return emptyList()
            return list.map { item -> getMap(item) }
        }

        @JvmStatic
        fun <T> SalesIQResult<T>.sendResult(
            result: MethodChannel.Result?,
            resultType: ResultType = ResultType.DirectValue,
        ) {
            if (result == null) {
                return
            }

            handler.post {
                if (isSuccess && data != null) {
                    val output = when (resultType) {
                        ResultType.ListMap -> {
                            getMapList(data)
                        }

                        ResultType.Map -> {
                            getMap(data)
                        }

                        else -> {
                            data
                        }
                    }
                    result.success(output)
                } else {
                    result.error(error?.code?.toString() ?: "UNKNOWN_ERROR", error?.message, null)
                }
            }
        }

        @JvmStatic
        fun <T> SalesIQResult<T>.sendResult(
            result: MethodChannel.Result?,
            value: Any?,
        ) {
            if (result == null) {
                return
            }

            handler.post {
                if (isSuccess && data != null) {
                    result.success(value)
                } else {
                    result.error(error?.code?.toString() ?: "UNKNOWN_ERROR", error?.message, null)
                }
            }
        }

        @JvmStatic
        fun getSalesIQConversationAttributes(
            call: MethodCall,
        ): SalesIQConversationAttributes? {
            val departments = call.argument<List<Map<String, Any?>>?>("departments")
            val name = call.argument<String?>("name")
            val additionalInfo = call.argument<String?>("additionalInfo")
            val displayPicture = call.argument<String?>("displayPicture")
            val customSecretFields = call.argument<Map<String, String>?>("custom_secret_fields")
            if (name == null && additionalInfo == null && displayPicture == null && departments == null && customSecretFields == null) {
                return null
            }
            val builder = SalesIQConversationAttributes.Builder()
            name?.let { builder.setName(it) }
            additionalInfo?.let { builder.setAdditionalInfo(it) }
            displayPicture?.let { builder.setDisplayPicture(it) }
            customSecretFields?.let { builder.setCustomSecretFields(it) }
            runCatching {
                val listType = object : TypeToken<List<SIQDepartment>?>() {}.type
                departments?.let {
                    builder.setDepartments(gson.fromJson(gson.toJson(it), listType))
                }
            }
            return builder.build()
        }
    }
}