package com.phucnote.pdf_functional_poc

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.pdf.PdfRenderer
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors
import kotlin.math.roundToInt
import kotlin.math.sqrt

/** Example-only bridge. Every renderer/page/descriptor operation uses one worker. */
class PdfBridge(private val context: Context) {
    private data class Document(val file: File, val renderer: PdfRenderer)
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val documents = mutableMapOf<Int, Document>()
    private var nextId = 0
    private var renders = 0
    @Volatile private var detached = false

    fun handle(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        if (detached) { result.error("CLOSED", "Engine closed", null); return }
        worker.execute {
            try {
                val response: Any? = when (call.method) {
                    "open" -> {
                        val bytes = call.argument<ByteArray>("bytes") ?: error("Missing PDF bytes")
                        require(bytes.isNotEmpty() && bytes.size <= 32 * 1024 * 1024)
                        require(documents.size < 2)
                        val file = File.createTempFile("pdf-poc-", ".pdf", context.cacheDir)
                        var descriptor: ParcelFileDescriptor? = null
                        var renderer: PdfRenderer? = null
                        try {
                            file.writeBytes(bytes)
                            descriptor = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                            val opened = PdfRenderer(descriptor)
                            renderer = opened
                            // Renderer owns the descriptor after successful construction.
                            descriptor = null
                            require(opened.pageCount in 1..500)
                            val sizes = (0 until opened.pageCount).map { index ->
                                opened.openPage(index).use { page ->
                                    mapOf("width" to page.width, "height" to page.height)
                                }
                            }
                            val id = ++nextId
                            documents[id] = Document(file, opened)
                            renderer = null
                            mapOf("id" to id, "pages" to sizes)
                        } catch (error: Throwable) {
                            renderer?.close()
                            descriptor?.close()
                            file.delete()
                            throw error
                        }
                    }
                    "render" -> {
                        val id = call.argument<Int>("id") ?: error("Missing id")
                        val index = call.argument<Int>("page") ?: error("Missing page")
                        val wantedWidth = call.argument<Int>("width") ?: error("Missing width")
                        require(wantedWidth in 1..4096)
                        val renderer = documents[id]?.renderer ?: error("Document closed")
                        val started = System.nanoTime()
                        renderer.openPage(index).use { page ->
                            var width = wantedWidth
                            var height = (width.toDouble() * page.height / page.width).roundToInt().coerceAtLeast(1)
                            if (width.toLong() * height > 4_000_000) {
                                val factor = sqrt(4_000_000.0 / (width.toDouble() * height))
                                width = (width * factor).toInt().coerceAtLeast(1)
                                height = (height * factor).toInt().coerceAtLeast(1)
                            }
                            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                            try {
                                bitmap.eraseColor(Color.WHITE)
                                val matrix = Matrix().apply {
                                    setScale(width.toFloat() / page.width, height.toFloat() / page.height)
                                }
                                page.render(bitmap, null, matrix, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                                val stream = ByteArrayOutputStream()
                                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                                renders++
                                mapOf("bytes" to stream.toByteArray(), "width" to width, "height" to height,
                                    "page" to index, "id" to id, "renderMs" to (System.nanoTime() - started) / 1_000_000.0)
                            } finally { bitmap.recycle() }
                        }
                    }
                    "close" -> {
                        close(call.argument<Int>("id") ?: error("Missing id"))
                        null
                    }
                    "stats" -> mapOf("documents" to documents.size, "renders" to renders)
                    else -> error("Unknown method")
                }
                main.post { if (!detached) result.success(response) }
            } catch (error: Throwable) {
                main.post { if (!detached) result.error("PDF_FAILURE", error.javaClass.simpleName, null) }
            }
        }
    }

    private fun close(id: Int) {
        documents.remove(id)?.let { document ->
            try { document.renderer.close() } finally { document.file.delete() }
        }
    }

    fun dispose() {
        detached = true
        worker.execute { documents.keys.toList().forEach { close(it) } }
        worker.shutdown()
    }
}
