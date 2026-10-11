package com.phucnote.phucnote

import android.app.Activity
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.view.Choreographer
import android.view.FrameMetrics
import android.view.MotionEvent
import android.view.Window
import java.util.ArrayDeque

/** Optional observer only: events are passed to Flutter unchanged. */
class StylusDiagnostics(private val activity: Activity) {
    private val capacity = 10000
    private val samples = ArrayDeque<Map<String, Any?>>()
    private val vsync = ArrayDeque<Long>()
    private val windowFrames = ArrayDeque<Map<String, Any>>()
    private val devices = linkedMapOf<Int, Map<String, Any?>>()
    private val refreshChanges = mutableListOf<Map<String, Any>>()
    private var droppedSamples = 0
    private var droppedVsync = 0
    private var droppedWindowFrames = 0
    private var platformDroppedWindowReports = 0
    private var cancellations = 0
    private var events = 0
    private var historicalSamples = 0
    private var startedMs = 0L
    private var stoppedMs = 0L
    private var enabled = false
    val recording: Boolean get() = enabled
    private var lastRefresh: Float? = null

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(timeNanos: Long) {
            if (!enabled) return
            if (vsync.size == capacity) { vsync.removeFirst(); droppedVsync++ }
            vsync.addLast(timeNanos)
            observeRefresh()
            Choreographer.getInstance().postFrameCallback(this)
        }
    }
    private val windowListener = Window.OnFrameMetricsAvailableListener { _, metrics, dropped ->
        if (enabled) {
            if (windowFrames.size == capacity) { windowFrames.removeFirst(); droppedWindowFrames++ }
            platformDroppedWindowReports += dropped
            windowFrames.addLast(mapOf(
                "totalNs" to metrics.getMetric(FrameMetrics.TOTAL_DURATION),
                "drawNs" to metrics.getMetric(FrameMetrics.DRAW_DURATION),
                "intendedVsyncNs" to metrics.getMetric(FrameMetrics.INTENDED_VSYNC_TIMESTAMP)
            ))
        }
    }

    fun start(): Map<String, Any?> {
        stop()
        samples.clear(); vsync.clear(); windowFrames.clear(); devices.clear(); refreshChanges.clear()
        droppedSamples = 0; droppedVsync = 0; droppedWindowFrames = 0
        platformDroppedWindowReports = 0; cancellations = 0; events = 0; historicalSamples = 0
        startedMs = SystemClock.uptimeMillis(); stoppedMs = 0; lastRefresh = null
        enabled = true
        observeRefresh()
        activity.window.addOnFrameMetricsAvailableListener(windowListener, Handler(Looper.getMainLooper()))
        Choreographer.getInstance().postFrameCallback(frameCallback)
        return snapshot()
    }

    fun stop(): Map<String, Any?> {
        if (enabled) {
            enabled = false
            stoppedMs = SystemClock.uptimeMillis()
            Choreographer.getInstance().removeFrameCallback(frameCallback)
            activity.window.removeOnFrameMetricsAvailableListener(windowListener)
        }
        return snapshot()
    }

    private fun observeRefresh() {
        val rate = activity.window.decorView.display?.refreshRate ?: return
        if (rate != lastRefresh) {
            // Bound even pathological display mode switching.
            if (refreshChanges.size < 1000) refreshChanges.add(mapOf("uptimeMs" to SystemClock.uptimeMillis(), "hz" to rate))
            lastRefresh = rate
        }
    }

    fun observe(event: MotionEvent) {
        if (!enabled) return
        events++
        if (event.actionMasked == MotionEvent.ACTION_CANCEL) cancellations++
        if (!devices.containsKey(event.deviceId)) {
            val device = event.device
            devices[event.deviceId] = mapOf(
                "name" to device?.name, "sources" to device?.sources,
                "ranges" to listOf(MotionEvent.AXIS_PRESSURE, MotionEvent.AXIS_TILT, MotionEvent.AXIS_ORIENTATION).associate { axis ->
                    val range = device?.getMotionRange(axis, event.source)
                    axis.toString() to range?.let { mapOf("min" to it.min, "max" to it.max, "flat" to it.flat, "fuzz" to it.fuzz, "resolution" to it.resolution) }
                }
            )
        }
        for (history in 0 until event.historySize) {
            for (pointer in 0 until event.pointerCount) record(event, pointer, history)
        }
        for (pointer in 0 until event.pointerCount) record(event, pointer, -1)
    }

    private fun record(event: MotionEvent, pointer: Int, history: Int) {
        val historical = history >= 0
        if (historical) historicalSamples++
        if (samples.size == capacity) { samples.removeFirst(); droppedSamples++ }
        samples.addLast(mapOf(
            "uptimeMs" to if (historical) event.getHistoricalEventTime(history) else event.eventTime,
            "receivedUptimeMs" to SystemClock.uptimeMillis(),
            "deviceId" to event.deviceId, "pointerId" to event.getPointerId(pointer), "pointerIndex" to pointer,
            "toolType" to event.getToolType(pointer), "source" to event.source,
            "action" to event.actionMasked, "actionIndex" to event.actionIndex,
            "flags" to event.flags, "buttons" to event.buttonState, "historical" to historical,
            "xPx" to if (historical) event.getHistoricalX(pointer, history) else event.getX(pointer),
            "yPx" to if (historical) event.getHistoricalY(pointer, history) else event.getY(pointer),
            "pressure" to if (historical) event.getHistoricalPressure(pointer, history) else event.getPressure(pointer),
            "tiltRad" to if (historical) event.getHistoricalAxisValue(MotionEvent.AXIS_TILT, pointer, history) else event.getAxisValue(MotionEvent.AXIS_TILT, pointer),
            "orientationRad" to if (historical) event.getHistoricalOrientation(pointer, history) else event.getOrientation(pointer),
            "size" to if (historical) event.getHistoricalSize(pointer, history) else event.getSize(pointer),
            "touchMajorPx" to if (historical) event.getHistoricalTouchMajor(pointer, history) else event.getTouchMajor(pointer)
        ))
    }

    private fun property(key: String): String? = try {
        ProcessBuilder("/system/bin/getprop", key).start().inputStream.bufferedReader().use { it.readText().trim().ifEmpty { null } }
    } catch (_: Exception) { null }

    private fun snapshot(): Map<String, Any?> = mapOf(
        "model" to Build.MODEL, "manufacturer" to Build.MANUFACTURER,
        "device" to Build.DEVICE, "androidRelease" to Build.VERSION.RELEASE,
        "sdk" to Build.VERSION.SDK_INT, "buildDisplay" to Build.DISPLAY,
        "zuiProperties" to mapOf("ro.zui.version" to property("ro.zui.version"), "ro.build.version.zui" to property("ro.build.version.zui")),
        "refreshHz" to activity.window.decorView.display?.refreshRate,
        "refreshChanges" to refreshChanges.toList(), "recording" to enabled,
        "startedUptimeMs" to startedMs, "stoppedUptimeMs" to stoppedMs,
        "events" to events, "cancellations" to cancellations, "historicalSamples" to historicalSamples,
        "devices" to devices.mapKeys { it.key.toString() }, "samples" to samples.toList(),
        "vsyncNs" to vsync.toList(), "windowFrames" to windowFrames.toList(),
        "capacity" to capacity, "droppedSamples" to droppedSamples,
        "droppedVsync" to droppedVsync, "droppedWindowFrames" to droppedWindowFrames,
        "platformDroppedWindowReports" to platformDroppedWindowReports
    )
}
