package com.example.aurenix

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * The `aurenix/screen_share` channel: asks the user for screen capture
 * consent, runs [ScreenShareService] while sharing, and returns screenshots.
 */
class ScreenShare(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    companion object {
        private const val REQUEST_CODE = 23646
    }

    private val channel = MethodChannel(messenger, "aurenix/screen_share")
    private val encoder = Executors.newSingleThreadExecutor()

    /** The `start` call waiting on the consent dialog, with its notification text. */
    private var pending: MethodChannel.Result? = null
    private var pendingArgs: Map<String, String> = emptyMap()

    init {
        channel.setMethodCallHandler(this)
        ScreenShareService.onStopped = { channel.invokeMethod("stopped", null) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isSharing" -> result.success(ScreenShareService.isSharing)
            "start" -> start(call, result)
            "capture" -> capture(call, result)
            "stop" -> {
                ScreenShareService.instance?.stop()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        if (pending != null) return result.error("busy", "Already asking for consent", null)
        if (ScreenShareService.isSharing) return result.success(true)
        pending = result
        pendingArgs = listOf(
            ScreenShareService.EXTRA_CHANNEL_NAME,
            ScreenShareService.EXTRA_TITLE,
            ScreenShareService.EXTRA_TEXT,
        ).associateWith { call.argument<String>(it) ?: "" }
        val manager = activity.getSystemService(Activity.MEDIA_PROJECTION_SERVICE)
            as MediaProjectionManager
        activity.startActivityForResult(manager.createScreenCaptureIntent(), REQUEST_CODE)
    }

    /** True when this was the consent dialog's result. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val result = pending ?: return true
        pending = null
        if (resultCode != Activity.RESULT_OK || data == null) {
            result.success(false)
            return true
        }
        val intent = Intent(activity, ScreenShareService::class.java)
            .setAction(ScreenShareService.ACTION_START)
            .putExtra(ScreenShareService.EXTRA_RESULT_CODE, resultCode)
            .putExtra(ScreenShareService.EXTRA_RESULT_DATA, data)
        for ((key, value) in pendingArgs) intent.putExtra(key, value)
        if (Build.VERSION.SDK_INT >= 26) {
            activity.startForegroundService(intent)
        } else {
            activity.startService(intent)
        }
        result.success(true)
        return true
    }

    private fun capture(call: MethodCall, result: MethodChannel.Result) {
        val maxSide = call.argument<Int>("maxSide") ?: 1280
        val quality = call.argument<Int>("quality") ?: 70
        // JPEG encoding takes tens of milliseconds; keep it off the UI thread.
        encoder.execute {
            val bytes = try {
                ScreenShareService.instance?.capture(maxSide, quality)
            } catch (_: Exception) {
                null
            }
            activity.runOnUiThread { result.success(bytes) }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        ScreenShareService.onStopped = null
        pending?.success(false)
        pending = null
        encoder.shutdown()
    }
}
