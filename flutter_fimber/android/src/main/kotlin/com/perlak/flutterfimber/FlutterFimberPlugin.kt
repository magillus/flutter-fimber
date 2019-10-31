package com.perlak.flutterfimber

import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterFimberPlugin : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_fimber")
            channel.setMethodCallHandler(FlutterFimberPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "log") {
            val logLevel = call.argument<String>("level")
            val tag = call.argument<String>("tag")
            val msg = call.argument<String>("message")
            val exDump = call.argument<String>("ex")
            val preFix = call.argument<String?>("preFix") ?: ""
            val postFix = call.argument<String?>("postFix") ?: ""
            val priority = when (logLevel) {
                "D" -> Log.DEBUG
                "I" -> Log.INFO
                "W" -> Log.WARN
                "E" -> Log.ERROR
                "F" -> Log.ASSERT
                else -> Log.VERBOSE
            }
            val msgWithException = msg + if (exDump?.isNotBlank() == true) {
                '\n'.toString() + exDump
            } else ""
            Log.println(priority, tag, preFix + msgWithException + postFix);
            result.success(0)
        } else {
            result.notImplemented()
        }
    }
}