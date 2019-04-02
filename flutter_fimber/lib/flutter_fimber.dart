import 'package:fimber/colorize.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'package:fimber/fimber.dart';

class FimberTree extends LogTree {
  static const List<String> DEFAULT = ["D", "I", "W", "E"];
  static final Map<String, ColorizeStyle> _defaultColorizeMap = {
    "V": ColorizeStyle([AnsiStyle.foreground(AnsiColor.BLUE)]),
    "D": ColorizeStyle([AnsiStyle.foreground(AnsiColor.GREEN)]),
    "W": ColorizeStyle([
      AnsiStyle.foreground(AnsiColor.YELLOW),
      AnsiStyle.background(AnsiColor.BLACK)
    ]),
    "E": ColorizeStyle([
      AnsiStyle.bright(AnsiColor.WHITE),
      AnsiStyle.background(AnsiColor.RED)
    ])
  };

  List<String> logLevels;
  bool useColors = false;

  Map<String, ColorizeStyle> colorizeMap = {};

  FimberTree({this.logLevels = DEFAULT, this.useColors = false}) {
    if (useColors) {
      colorizeMap = _defaultColorizeMap;
    }
  }

  @override
  log(String level, String msg,
      {String tag, dynamic ex, StackTrace stacktrace}) {
    var logTag = tag ?? LogTree.getTag();
    var exDump;
    if (ex != null) {
      var tmpStacktrace =
          stacktrace?.toString()?.split('\n') ?? LogTree.getStacktrace();
      var stackTraceMessage =
      tmpStacktrace.map((stackLine) => "\t$stackLine").join("\n");
      exDump = "${ex.toString()} \n$stackTraceMessage";
    }
    String postFix, preFix;
    if (useColors) {
      if (_defaultColorizeMap[level] != null) {
        var postPrefix = _defaultColorizeMap[level]
            .wrap("PREFIX_SPLITTER")
            .split("PREFIX_SPLITTER");
        if (postPrefix.length == 2) {
          preFix = postPrefix[0];
          postFix = postPrefix[1];
        }
      }
    }
    var logLine = LogLine(level, logTag, msg, exceptionDump: exDump,
        postFix: postFix,
        preFix: preFix);
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
  String preFix;
  String postFix;

  LogLine(this.level, this.tag, this.message,
      {this.exceptionDump, this.preFix, this.postFix});

  // to use with message event
  ByteData serialize() {
    WriteBuffer buffer = WriteBuffer();
    _putString(buffer, level);
    _putString(buffer, tag);
    _putString(buffer, message);
    _putString(buffer, exceptionDump);
    _putString(buffer, preFix ?? "");
    _putString(buffer, postFix ?? "");
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
      "ex": exceptionDump,
      "preFix": preFix,
      "postFix": postFix
    };
  }
}

/// Logging tree that uses `debugPrint` which is not skipping log lines printed on Android
/// https://flutter.io/docs/testing/debugging#print-and-debugprint-with-flutter-logs
class DebugBufferTree extends DebugTree {
  DebugBufferTree({int printTimeType = DebugTree.TIME_CLOCK,
    List<String> logLevels = DebugTree.DEFAULT})
      : super(printTimeType: printTimeType, logLevels: logLevels);

  factory DebugBufferTree.elapsed({List<String> logLevels = DebugTree.DEFAULT}) {
    return DebugBufferTree(
        logLevels: logLevels, printTimeType: DebugTree.TIME_ELAPSED);
  }

  @override
  printLog(String logLine, {String level}) {
    debugPrint(logLine);
  }
}
