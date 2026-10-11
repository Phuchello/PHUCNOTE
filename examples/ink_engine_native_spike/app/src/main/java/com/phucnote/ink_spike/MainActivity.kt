package com.phucnote.ink_spike

import android.app.Activity
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.FrameMetrics
import android.view.InputDevice
import android.view.MotionEvent
import android.view.View
import android.widget.FrameLayout
import androidx.ink.authoring.InProgressStrokeId
import androidx.ink.authoring.InProgressStrokesFinishedListener
import androidx.ink.authoring.InProgressStrokesView
import androidx.ink.brush.Brush
import androidx.ink.brush.StockBrushes
import androidx.ink.rendering.android.canvas.CanvasStrokeRenderer
import androidx.ink.strokes.MutableStrokeInputBatch
import androidx.ink.strokes.Stroke
import androidx.input.motionprediction.MotionEventPredictor
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/** Separate package and process. No PHUCNOTE documents or production renderer. */
class MainActivity : Activity() {
    private lateinit var wet: InProgressStrokesView
    private lateinit var dry: View
    private lateinit var predictor: MotionEventPredictor
    private val handler = Handler(Looper.getMainLooper())
    private val renderer = CanvasStrokeRenderer.create()
    private val brush = Brush.createWithColorIntArgb(
        StockBrushes.pressurePen(StockBrushes.PressurePenVersion.V1), Color.BLACK, 5f, .1f)
    private val completed = mutableListOf<Stroke>()
    private val preview = mutableListOf<Stroke>()
    private val result = JSONObject()
    private val frames = JSONArray()
    private var active: InProgressStrokeId? = null
    private var status = "Đang chạy testbed AndroidX Ink 1.0.0…"
    private var destroyed = false
    private var historicalSamples = 0
    private var predictionSamples = 0
    private var resumes = 0
    private var pauses = 0
    private var expected = JSONArray()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        result.put("runId", intent.getStringExtra("RUN_ID") ?: System.currentTimeMillis().toString())
        val root = FrameLayout(this)
        dry = object : View(this) {
            override fun onDraw(canvas: Canvas) {
                canvas.drawColor(Color.rgb(249, 246, 239))
                val text = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.DKGRAY; textSize = 30f }
                canvas.drawText("PHUCNOTE · Native spike · Synthetic input only", 32f, 64f, text)
                canvas.drawText(status, 32f, 110f, text)
                canvas.drawText("Marker V1 / PressurePen V1 · No .bfly transfer", 32f, 160f, text)
                canvas.save(); canvas.translate(32f, 210f); canvas.scale(2.5f, 2.5f)
                val previewToScreen = Matrix().apply { setScale(2.5f, 2.5f) }
                preview.forEach { renderer.draw(canvas, it, previewToScreen) }
                canvas.restore()
                completed.forEach { renderer.draw(canvas, it, Matrix()) }
            }
        }
        wet = InProgressStrokesView(this)
        predictor = MotionEventPredictor.newInstance(wet)
        wet.addFinishedStrokesListener(object : InProgressStrokesFinishedListener {
            override fun onStrokesFinished(strokes: Map<InProgressStrokeId, Stroke>) {
                completed.addAll(strokes.values)
                dry.invalidate()
                wet.removeFinishedStrokes(strokes.keys)
            }
        })
        wet.setOnTouchListener { _, e ->
            val id = e.getPointerId(e.actionIndex)
            predictor.record(e)
            when (e.actionMasked) {
                MotionEvent.ACTION_DOWN -> active = wet.startStroke(e, id, brush)
                MotionEvent.ACTION_MOVE -> active?.let {
                    val prediction = predictor.predict()
                    try { wet.addToStroke(e, id, it, prediction) }
                    finally { prediction?.recycle() }
                }
                MotionEvent.ACTION_UP -> active?.let { wet.finishStroke(e, id, it); active = null }
                MotionEvent.ACTION_CANCEL -> active?.let { wet.cancelStroke(it, e); active = null }
            }
            true
        }
        root.addView(dry, FrameLayout.LayoutParams(-1, -1))
        root.addView(wet, FrameLayout.LayoutParams(-1, -1))
        setContentView(root)
        if (Build.VERSION.SDK_INT >= 24) window.addOnFrameMetricsAvailableListener({ _, m, dropped ->
            if (frames.length() < 2000) frames.put(JSONObject().apply {
                put("totalMs", m.getMetric(FrameMetrics.TOTAL_DURATION) / 1e6)
                put("drawMs", m.getMetric(FrameMetrics.DRAW_DURATION) / 1e6)
                put("droppedCallbacks", dropped)
            })
        }, handler)
        Thread {
            try {
                val geometry = if (intent.getBooleanExtra("SMOKE_ONLY", false))
                    JSONObject(File(filesDir, "native_results.json").readText()).getJSONObject("geometry")
                    else GeometryBench.run(brush)
                val catalog = JSONObject(assets.open("ink_traces.json").bufferedReader().use { it.readText() })
                val trace = catalog.getJSONArray("traces").getJSONObject(8).getJSONArray("strokes")
                val previews = mutableListOf<Stroke>()
                val marker = Brush.createWithColorIntArgb(StockBrushes.marker(StockBrushes.MarkerVersion.V1),
                    Color.rgb(22, 54, 90), 3f, .1f)
                for (pen in listOf(marker, brush)) for (i in 0 until trace.length()) {
                    val batch = MutableStrokeInputBatch()
                    val points = trace.getJSONArray(i)
                    for (j in 0 until points.length()) {
                        val p = JSONObject(points.getJSONObject(j).toString())
                        if (pen === brush) p.put("y", p.getDouble("y") + 100)
                        GeometryBench.add(batch, p)
                    }
                    previews.add(Stroke(pen, batch))
                }
                runOnUiThread {
                    if (destroyed) return@runOnUiThread
                    result.put("geometry", geometry)
                    result.put("geometryReusedForSmoke", intent.getBooleanExtra("SMOKE_ONLY", false))
                    result.put("model", Build.MODEL); result.put("api", Build.VERSION.SDK_INT)
                    result.put("refreshHz", window.decorView.display.refreshRate.toDouble())
                    preview.addAll(previews); dry.invalidate()
                    handler.postDelayed({ smoke(catalog) }, 500)
                }
            } catch (e: Throwable) { runOnUiThread { failure(e) } }
        }.start()
    }

    private fun event(action: Int, p: JSONObject, down: Long): MotionEvent {
        val props = MotionEvent.PointerProperties().apply { id = 7; toolType = MotionEvent.TOOL_TYPE_STYLUS }
        val coords = coords(p)
        return MotionEvent.obtain(down, down + p.getLong("timeUs") / 1000, action, 1,
            arrayOf(props), arrayOf(coords), 0, 0, 1f, 1f, 0, 0, InputDevice.SOURCE_STYLUS, 0)
    }
    private fun coords(p: JSONObject) = MotionEvent.PointerCoords().apply {
        x = p.getDouble("x").toFloat() * 3 + 32
        y = p.getDouble("y").toFloat() * 3 + 850
        pressure = p.getDouble("pressure").toFloat()
        setAxisValue(MotionEvent.AXIS_TILT, p.getDouble("tilt").toFloat())
        setAxisValue(MotionEvent.AXIS_ORIENTATION, 0f)
    }

    private fun smoke(catalog: JSONObject) {
        try {
            val points = catalog.getJSONArray("traces").getJSONObject(11)
                .getJSONArray("strokes").getJSONArray(0)
            expected = points
            val down = SystemClock.uptimeMillis()
            val first = event(MotionEvent.ACTION_DOWN, points.getJSONObject(0), down)
            active = wet.startStroke(first, 7, brush); predictor.record(first); first.recycle()
            fun step(index: Int) {
                if (destroyed || active == null) return
                try {
                    if (index >= points.length() - 1) {
                        val up = event(MotionEvent.ACTION_UP, points.getJSONObject(points.length() - 1), down)
                        wet.finishStroke(up, 7, active!!); up.recycle(); active = null
                        handler.postDelayed({ checkHandoff(points.length()) }, 1800)
                        return
                    }
                    val end = minOf(index + 3, points.length() - 2)
                    val move = event(MotionEvent.ACTION_MOVE, points.getJSONObject(index), down)
                    for (j in index + 1..end) {
                        val p = points.getJSONObject(j)
                        move.addBatch(down + p.getLong("timeUs") / 1000, arrayOf(coords(p)), 0)
                    }
                    historicalSamples += move.historySize
                    predictor.record(move)
                    val prediction = predictor.predict()
                    if (prediction != null) predictionSamples += prediction.historySize + 1
                    try { wet.addToStroke(move, 7, active!!, prediction) }
                    finally { prediction?.recycle(); move.recycle() }
                    handler.postDelayed({ step(end + 1) }, 33)
                } catch (e: Throwable) { failure(e) }
            }
            step(1)
        } catch (e: Throwable) { failure(e) }
    }

    private fun checkHandoff(expectedInputs: Int) {
        try {
            check(completed.size == 1) { "Completed handoff count ${completed.size}" }
            check(completed.single().inputs.size == expectedInputs) { "Historical samples lost" }
            val retained = JSONArray()
            var coordinateError = 0f
            var pressureError = 0f
            var tiltError = 0f
            var timeError = 0L
            for (i in 0 until expectedInputs) {
                val input = completed.single().inputs[i]
                val p = expected.getJSONObject(i)
                val c = coords(p)
                coordinateError = maxOf(coordinateError, kotlin.math.abs(input.x - c.x), kotlin.math.abs(input.y - c.y))
                pressureError = maxOf(pressureError, kotlin.math.abs(input.pressure - c.pressure))
                tiltError = maxOf(tiltError, kotlin.math.abs(input.tiltRadians - p.getDouble("tilt").toFloat()))
                timeError = maxOf(timeError, kotlin.math.abs(input.elapsedTimeMillis - p.getLong("timeUs") / 1000))
                retained.put(JSONObject().apply {
                    put("x", input.x.toDouble()); put("y", input.y.toDouble())
                    put("pressure", input.pressure.toDouble()); put("tilt", input.tiltRadians.toDouble())
                    put("elapsedMs", input.elapsedTimeMillis)
                })
            }
            result.put("nativeInputSamples", retained)
            result.put("maxCoordinateErrorPx", coordinateError.toDouble())
            result.put("maxPressureError", pressureError.toDouble())
            result.put("maxTiltErrorRad", tiltError.toDouble())
            result.put("maxTimestampErrorMs", timeError)
            result.put("exactInputFidelity", if (coordinateError == 0f && pressureError == 0f && tiltError == 0f && timeError == 0L) "PASS" else "FAIL")
            result.put("canonicalInput", "Unchanged benchmark JSON; native inputs are not a .bfly replacement")
            val p = JSONObject().apply { put("x", 30); put("y", 20); put("pressure", .5)
                put("tilt", 0); put("timeUs", 0) }
            val cancel = event(MotionEvent.ACTION_DOWN, p, SystemClock.uptimeMillis())
            val id = wet.startStroke(cancel, 7, brush)
            wet.cancelStroke(id, cancel); cancel.recycle()
            handler.postDelayed({
                try {
                    check(completed.size == 1) { "Cancelled ink committed" }
                    result.put("completedCount", completed.size)
                    result.put("completedInputCount", completed.single().inputs.size)
                    result.put("historySamplesSupplied", historicalSamples)
                    result.put("predictedSamplesOffered", predictionSamples)
                    result.put("cancelledGestureCommitted", false)
                    result.put("status", "PASS")
                    status = "PASS · Completed handoff / history / cancellation"
                    dry.invalidate(); export()
                    Log.i("InkSpike", "INK_SPIKE_PASS")
                } catch (e: Throwable) { failure(e) }
            }, 600)
        } catch (e: Throwable) { failure(e) }
    }
    private fun export() {
        result.put("windowFrames", frames)
        result.put("resumes", resumes); result.put("pauses", pauses)
        File(filesDir, "native_results.json").writeText(result.toString(2))
    }
    private fun failure(error: Throwable) {
        result.put("status", "FAIL"); result.put("error", error.toString())
        status = "FAIL · ${error.message}"; dry.invalidate(); export()
        Log.e("InkSpike", "INK_SPIKE_FAIL", error)
    }
    override fun onPause() {
        active?.let { wet.cancelStroke(it) }; active = null
        pauses++
        if (result.has("status")) export()
        super.onPause()
    }
    override fun onResume() {
        super.onResume(); resumes++
        if (result.has("status")) export()
    }
    override fun onDestroy() {
        destroyed = true; handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}
