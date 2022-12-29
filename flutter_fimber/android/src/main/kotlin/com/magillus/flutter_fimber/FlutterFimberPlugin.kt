package com.magillus.flutter_fimber

import android.util.Log
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterFimberPlugin */
class FlutterFimberPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_fimber")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
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

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
