package com.phucnote.ink_spike

import android.os.Debug
import androidx.ink.brush.Brush
import androidx.ink.brush.InputToolType
import androidx.ink.strokes.ImmutableStrokeInputBatch
import androidx.ink.strokes.InProgressStroke
import androidx.ink.strokes.MutableStrokeInputBatch
import androidx.ink.strokes.Stroke
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.sin

/** Synthetic CPU throughput only. No display-latency or engine-parity claim. */
object GeometryBench {
    fun add(batch: MutableStrokeInputBatch, p: JSONObject) {
        batch.add(InputToolType.STYLUS, p.getDouble("x").toFloat(),
            p.getDouble("y").toFloat(), p.getLong("timeUs") / 1000,
            0f, p.getDouble("pressure").toFloat(), p.getDouble("tilt").toFloat(), 0f)
    }

    private fun memory(): JSONObject = JSONObject().apply {
        put("javaHeapUsed", Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory())
        put("nativeHeapAllocated", Debug.getNativeHeapAllocatedSize())
        // ART counters cover Java allocation; native meshes are separate.
        put("art", JSONObject(Debug.getRuntimeStats()))
    }

    fun run(brush: Brush): JSONObject {
        val runs = JSONArray()
        val progress = InProgressStroke()
        for (count in listOf(128, 512, 2048, 4096)) {
            val samples = JSONArray()
            repeat(count) { i -> samples.put(JSONObject().apply {
                put("x", 20 + i * .8); put("y", 70 + 24 * sin(i * .09))
                put("pressure", .05 + .9 * i / (count - 1)); put("tilt", .2 + .1 * sin(i * .03))
                put("timeUs", i * 8333L)
            }) }
            val all = MutableStrokeInputBatch()
            val one = MutableStrokeInputBatch()
            val baseline = JSONArray()
            val incremental = JSONArray()
            val before = memory()
            progress.start(brush)
            repeat(count) { i ->
                val p = samples.getJSONObject(i)
                add(all, p)
                var begun = System.nanoTime()
                val rebuilt = Stroke(brush, all)
                baseline.put((System.nanoTime() - begun) / 1e6)
                check(rebuilt.inputs.size == i + 1)
                one.clear(); add(one, p)
                begun = System.nanoTime()
                progress.enqueueInputs(one, ImmutableStrokeInputBatch.EMPTY)
                progress.updateShape(p.getLong("timeUs") / 1000)
                incremental.put((System.nanoTime() - begun) / 1e6)
            }
            progress.finishInput(); progress.updateShape()
            val finished = progress.toImmutable()
            check(finished.inputs.size == count)
            runs.put(JSONObject().apply {
                put("length", count); put("nativeFullPrefixMs", baseline)
                put("nativeIncrementalMs", incremental); put("inputCount", finished.inputs.size)
                put("memoryBefore", before); put("memoryAfter", memory())
            })
        }
        return JSONObject().apply {
            put("kind", "native geometry microbenchmark, debug build, distinct brush geometry")
            put("runs", runs)
        }
    }
}
