package com.zoho.salesiq.mobilisten.calls.plugin.activity.lifecycle

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner

class ActivityLifecycleOwner(application: Application) : LifecycleOwner, SavedStateRegistryOwner {
    private val lifecycleRegistry = LifecycleRegistry(this)
    private val savedStateRegistryController = SavedStateRegistryController.create(this)
    private var isRestored = false

    init {
        application.registerActivityLifecycleCallbacks(object :
            Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                if (activity == this@ActivityLifecycleOwner.currentActivity || this@ActivityLifecycleOwner.currentActivity == null) {
                    savedStateRegistryController.performAttach()
                    if (!isRestored) {
                        savedStateRegistryController.performRestore(savedInstanceState)
                        isRestored = true
                    }
                    lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE)
                }
            }

            override fun onActivityStarted(activity: Activity) {
                if (activity == this@ActivityLifecycleOwner.currentActivity) {
                    lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
                }
            }

            override fun onActivityResumed(activity: Activity) {
                if (activity == this@ActivityLifecycleOwner.currentActivity) {
                    lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
                }
            }

            override fun onActivityPaused(activity: Activity) {
                if (activity == this@ActivityLifecycleOwner.currentActivity) {
                    lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
                }
            }

            override fun onActivityStopped(activity: Activity) {
                if (activity == this@ActivityLifecycleOwner.currentActivity) {
                    lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
                }
            }

            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
                if (activity == this@ActivityLifecycleOwner.currentActivity) {
                    savedStateRegistryController.performSave(outState)
                }
            }

            override fun onActivityDestroyed(activity: Activity) {
                if (activity == this@ActivityLifecycleOwner.currentActivity) {
                    lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY)
                    activity.application.unregisterActivityLifecycleCallbacks(this)
                }
            }
        })
    }

    override val lifecycle: Lifecycle
        get() = lifecycleRegistry

    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    var currentActivity: Activity? = null
}