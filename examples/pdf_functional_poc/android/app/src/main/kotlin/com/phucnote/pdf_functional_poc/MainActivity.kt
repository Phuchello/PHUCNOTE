package com.phucnote.pdf_functional_poc

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var bridge: PdfBridge? = null
    private var channel: MethodChannel? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val instance = PdfBridge(applicationContext)
        bridge = instance
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "phucnote_pdf_poc")
        channel!!.setMethodCallHandler(instance::handle)
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
        bridge?.dispose()
        bridge = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
