import 'dart:async';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'package:fimber/fimber.dart';

class FimberTree extends LogTree {
  static const List<String> DEFAULT = ["D", "I", "W", "E"];
  List<String> logLevels;

  FimberTree({this.logLevels = DEFAULT});

  @override
  log(String level, String msg, {String tag, Exception ex}) {
    var logTag = tag ?? LogTree.getTag();
    _channel.invokeMethod("log",
        LogLine(level, logTag, msg, exceptionDump: ex?.toString() ?? ''));
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }

  static const MethodChannel _channel = const MethodChannel('flutter_fimber');

}

/// Transport object to native value
class LogLine {
  String level;
  String tag;
  String message;
  String exceptionDump;

  LogLine(this.level, this.tag, this.message, {this.exceptionDump});
}

/// Logging tree that uses `debugPrint` which is not skipping log lines printed on Android
/// https://flutter.io/docs/testing/debugging#print-and-debugprint-with-flutter-logs
class DebugBufferTree extends DebugTree {
  @override
  printLog(String logLine) {
    debugPrint(logLine);
  }
}
