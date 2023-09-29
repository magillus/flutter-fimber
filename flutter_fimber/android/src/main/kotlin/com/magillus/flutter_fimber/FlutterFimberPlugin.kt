package com.magillus.flutter_fimber

import android.util.Log
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

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_fimber")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "log" -> log(call, result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun log(call: MethodCall, result: Result) {
    val tag = call.argument<String?>("tag") ?: "flutter"
    val message = call.argument<String?>("message") ?: ""
    val level = call.argument<String?>("level") ?: "V"
    val throwable = call.argument<String?>("ex")?.let { Throwable(it) }

    when (level) {
      "V" -> Log.v(tag, message, throwable)
      "D" -> Log.d(tag, message, throwable)
      "I" -> Log.i(tag, message, throwable)
      "W" -> Log.w(tag, message, throwable)
      "E" -> Log.e(tag, message, throwable)
      "WTF" -> Log.wtf(tag, message, throwable)
      else -> Log.d(tag, message, throwable)
    }
    result.success(null)
  }
}
