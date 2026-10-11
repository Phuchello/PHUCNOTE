package com.phucnote.phucnote

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.MotionEvent

class MainActivity : FlutterActivity() {
    private var diagnostics: StylusDiagnostics? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val observer = StylusDiagnostics(this)
        diagnostics = observer
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "phucnote/stylus_diagnostics")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> result.success(observer.start())
                    "stop" -> result.success(observer.stop())
                    else -> result.notImplemented()
                }
            }
    }

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        diagnostics?.observe(event)
        return super.dispatchTouchEvent(event)
    }

    override fun dispatchGenericMotionEvent(event: MotionEvent): Boolean {
        diagnostics?.observe(event)
        return super.dispatchGenericMotionEvent(event)
    }

    override fun onPause() {
        if (diagnostics?.recording == true) diagnostics?.stop()
        super.onPause()
    }
}
