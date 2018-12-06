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
    var exDump;
    if (ex != null) {
      var stackTrace = LogTree.getStacktrace().map((
          stackLine) => "\t$stackLine").join("\n");
      exDump = "${ex.toString()} \n$stackTrace";
    }
    var logLine = LogLine(level, logTag, msg,
        exceptionDump: exDump);
    var invokeMsg = logLine.toMsg();
    _channel.invokeMethod("log", invokeMsg);
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

  // to use with message event
  ByteData serialize() {
    WriteBuffer buffer = WriteBuffer();
    _putString(buffer, level);
    _putString(buffer, tag);
    _putString(buffer, message);
    _putString(buffer, exceptionDump);
    return buffer.done();
  }

  _putString(WriteBuffer buffer, String value) {
    buffer.putUint8(0xfe);
    buffer.putInt32(value.length);
    value.runes.map((int rune) {
      buffer.putInt32(rune);
    });
  }

  // to use with method call
  dynamic toMsg() {
    return {
      "level": level,
      "tag": tag,
      "message": message,
      "ex": exceptionDump
    };
  }
}

/// Logging tree that uses `debugPrint` which is not skipping log lines printed on Android
/// https://flutter.io/docs/testing/debugging#print-and-debugprint-with-flutter-logs
class DebugBufferTree extends DebugTree {
  @override
  printLog(String logLine) {
    debugPrint(logLine);
  }
}
