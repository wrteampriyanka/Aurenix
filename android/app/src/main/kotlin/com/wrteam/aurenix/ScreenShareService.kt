package com.wrteam.aurenix

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import kotlin.math.max

/**
 * Mirrors the screen into an [ImageReader] and hands out the latest frame as a
 * JPEG on request. Runs as a foreground service, which Android requires for
 * screen capture, and which keeps the share alive while the user is in other
 * apps showing things to the AI.
 */
class ScreenShareService : Service() {
    companion object {
        const val ACTION_START = "com.wrteam.aurenix.screen_share.START"
        const val EXTRA_RESULT_CODE = "result_code"
        const val EXTRA_RESULT_DATA = "result_data"
        const val EXTRA_CHANNEL_NAME = "channel_name"
        const val EXTRA_TITLE = "title"
        const val EXTRA_TEXT = "text"

        private const val TAG = "ScreenShare"
        private const val CHANNEL_ID = "screen_share"
        private const val NOTIFICATION_ID = 4821

        /** Longest side of the mirrored display; enough to read text. */
        private const val MAX_SIDE = 1440

        /** The running service, while there is one. */
        @Volatile
        var instance: ScreenShareService? = null

        /** Called on the main thread whenever the share ends, for any reason. */
        @Volatile
        var onStopped: (() -> Unit)? = null

        val isSharing: Boolean get() = instance?.projection != null
    }

    private val thread = HandlerThread("screen_share").apply { start() }
    private val handler = Handler(thread.looper)

    /** Guards [latest], which the capture thread reads and [handler] writes. */
    private val frameLock = Any()

    private var projection: MediaProjection? = null
    private var display: VirtualDisplay? = null
    private var reader: ImageReader? = null
    private var latest: Image? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action != ACTION_START) {
            stopSelf()
            return START_NOT_STICKY
        }
        // Android 14+ only hands out the projection to a foreground service.
        startInForeground(
            intent.getStringExtra(EXTRA_CHANNEL_NAME) ?: "Screen sharing",
            intent.getStringExtra(EXTRA_TITLE) ?: "",
            intent.getStringExtra(EXTRA_TEXT) ?: "",
        )
        val code = intent.getIntExtra(EXTRA_RESULT_CODE, Activity.RESULT_CANCELED)
        val data: Intent? = if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(EXTRA_RESULT_DATA, Intent::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(EXTRA_RESULT_DATA)
        }
        if (data == null || projection != null) {
            stop()
            return START_NOT_STICKY
        }
        try {
            startProjection(code, data)
        } catch (e: Exception) {
            Log.w(TAG, "Screen capture failed to start", e)
            stop()
        }
        return START_NOT_STICKY
    }

    private fun startInForeground(channelName: String, title: String, text: String) {
        val builder = if (Build.VERSION.SDK_INT >= 26) {
            getSystemService(NotificationManager::class.java).createNotificationChannel(
                NotificationChannel(CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_LOW)
            )
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        // Tapping the notification brings the user back to live talk.
        val open = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val notification = builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(open)
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= 29) {
            var type = ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
            // Lets speech recognition keep the microphone while the user is
            // in another app.
            val hasMic = checkSelfPermission(android.Manifest.permission.RECORD_AUDIO) ==
                PackageManager.PERMISSION_GRANTED
            if (Build.VERSION.SDK_INT >= 30 && hasMic) {
                type = type or ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            }
            startForeground(NOTIFICATION_ID, notification, type)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    @Synchronized
    private fun startProjection(code: Int, data: Intent) {
        val manager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val projection = manager.getMediaProjection(code, data)
            ?: throw IllegalStateException("No media projection")
        // Must be registered before the display exists on Android 14+. It
        // also fires when the user stops the share from the status bar.
        projection.registerCallback(object : MediaProjection.Callback() {
            override fun onStop() = stop()
        }, handler)
        val (width, height, dpi) = displaySize()
        val reader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 3)
        reader.setOnImageAvailableListener({ r ->
            val image = r.acquireLatestImage() ?: return@setOnImageAvailableListener
            synchronized(frameLock) {
                latest?.close()
                latest = image
            }
        }, handler)
        display = projection.createVirtualDisplay(
            "aurenix_screen_share",
            width,
            height,
            dpi,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            reader.surface,
            null,
            handler,
        )
        this.reader = reader
        this.projection = projection
    }

    /** The screen, scaled down to [MAX_SIDE] when larger, as width, height, dpi. */
    private fun displaySize(): Triple<Int, Int, Int> {
        val wm = getSystemService(WINDOW_SERVICE) as WindowManager
        var width: Int
        var height: Int
        val dpi: Int
        if (Build.VERSION.SDK_INT >= 30) {
            val bounds = wm.maximumWindowMetrics.bounds
            width = bounds.width()
            height = bounds.height()
            dpi = resources.configuration.densityDpi
        } else {
            val metrics = DisplayMetrics()
            @Suppress("DEPRECATION")
            wm.defaultDisplay.getRealMetrics(metrics)
            width = metrics.widthPixels
            height = metrics.heightPixels
            dpi = metrics.densityDpi
        }
        val scale = MAX_SIDE.toFloat() / max(width, height)
        if (scale < 1f) {
            width = (width * scale).toInt()
            height = (height * scale).toInt()
        }
        // Encoders want even sizes.
        return Triple(width and 1.inv(), height and 1.inv(), dpi)
    }

    /** The latest frame as a JPEG, or null before the first frame arrives. */
    fun capture(maxSide: Int, quality: Int): ByteArray? {
        val bitmap = synchronized(frameLock) { latest?.let(::toBitmap) } ?: return null
        val scale = maxSide.toFloat() / max(bitmap.width, bitmap.height)
        val scaled = if (scale < 1f) {
            Bitmap.createScaledBitmap(
                bitmap,
                max(1, (bitmap.width * scale).toInt()),
                max(1, (bitmap.height * scale).toInt()),
                true,
            )
        } else {
            bitmap
        }
        val out = ByteArrayOutputStream()
        scaled.compress(Bitmap.CompressFormat.JPEG, quality, out)
        if (scaled !== bitmap) scaled.recycle()
        bitmap.recycle()
        return out.toByteArray()
    }

    private fun toBitmap(image: Image): Bitmap {
        val plane = image.planes[0]
        // Rows are padded, so build the bitmap at the padded width and crop.
        val stride = plane.rowStride / plane.pixelStride
        val needed = stride * image.height * 4
        val source = plane.buffer.duplicate().apply { rewind() }
        val buffer = if (source.remaining() >= needed) {
            source
        } else {
            ByteBuffer.allocate(needed).also { it.put(source); it.rewind() }
        }
        val full = Bitmap.createBitmap(stride, image.height, Bitmap.Config.ARGB_8888)
        full.copyPixelsFromBuffer(buffer)
        if (stride == image.width) return full
        val cropped = Bitmap.createBitmap(full, 0, 0, image.width, image.height)
        full.recycle()
        return cropped
    }

    /** Ends the share and the service. Safe to call more than once. */
    @Synchronized
    fun stop() {
        val wasSharing = projection != null
        // Null first: stopping the projection calls back into here.
        val projection = this.projection
        this.projection = null
        synchronized(frameLock) {
            latest?.close()
            latest = null
        }
        display?.release()
        display = null
        reader?.close()
        reader = null
        projection?.stop()
        if (Build.VERSION.SDK_INT >= 33) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        stopSelf()
        if (wasSharing) Handler(Looper.getMainLooper()).post { onStopped?.invoke() }
    }

    override fun onDestroy() {
        stop()
        thread.quitSafely()
        if (instance === this) instance = null
        super.onDestroy()
    }
}
