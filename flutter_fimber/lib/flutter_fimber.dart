import 'package:fimber/colorize.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'package:fimber/fimber.dart';

/// Fimber logging tree for specific platform.
/// For Android it uses Android Log with corresponding levels and formatting
class FimberTree extends LogTree {
  /// Default log levels.
  static const List<String> defaultLevels = ["D", "I", "W", "E"];
  static final Map<String, ColorizeStyle> _defaultColorizeMap = {
    "V": ColorizeStyle([AnsiStyle.foreground(AnsiColor.blue)]),
    "D": ColorizeStyle([AnsiStyle.foreground(AnsiColor.green)]),
    "W": ColorizeStyle([
      AnsiStyle.foreground(AnsiColor.yellow),
      AnsiStyle.background(AnsiColor.black)
    ]),
    "E": ColorizeStyle([
      AnsiStyle.bright(AnsiColor.white),
      AnsiStyle.background(AnsiColor.red)
    ])
  };

  /// Log levels for this Log Tree
  List<String> logLevels;

  /// Toggle to use colors scheme for ANSI style.
  bool useColors = false;

  /// Optional list of Color style per each level.
  Map<String, ColorizeStyle> colorizeMap = {};

  /// Creates instance of FimberTree
  /// with optional allowed [logLevels] and [useColors] flag.
  FimberTree({this.logLevels = defaultLevels, this.useColors = false}) {
    if (useColors) {
      colorizeMap = _defaultColorizeMap;
    }
  }

  /// Logs [message] with log [level]
  /// and optional [tag], [ex] (exception) and [stacktrace]
  @override
  void log(String level, String message,
      {String tag, dynamic ex, StackTrace stacktrace}) {
    var logTag = tag ?? LogTree.getTag();
    String exDump;
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
    var logLine = LogLine(level, logTag, message,
        exceptionDump: exDump, postFix: postFix, preFix: preFix);
    var invokeMsg = logLine.toMsg();
    _channel.invokeMethod("log", invokeMsg);
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }

  /// Method channel to send log information to native OS to handle.
  static const MethodChannel _channel = MethodChannel('flutter_fimber');
}

/// Transport object to native value
class LogLine {
  /// Log level
  String level;

  /// Log tag
  String tag;

  /// Log message
  String message;

  /// Exception dump if attached to log line.
  String exceptionDump;

  /// Log line prefix.
  String preFix;

  /// Log line postfix.
  String postFix;

  /// Creates instance of [LogLine] with optional fields.
  LogLine(this.level, this.tag, this.message,
      {this.exceptionDump, this.preFix, this.postFix});

  /// Serializes the [LogLine] to Byte array
  ByteData serialize() {
    var buffer = WriteBuffer();
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
    value.runes.map((rune) {
      buffer.putInt32(rune);
    });
  }

  /// to use with method call
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

/// Logging tree that uses `debugPrint`
/// which is not skipping log lines printed on Android
/// https://flutter.io/docs/testing/debugging#print-and-debugprint-with-flutter-logs
class DebugBufferTree extends DebugTree {
  /// Max limit that a log can reach to start dividing it into multiple chunks
  /// avoiding them to be cut by android log
  /// - when -1 will disable chunking of the logs
  final int maxLineSize;

  /// Creates Debug Tree compatible with Android.
  DebugBufferTree({
    int printTimeType = DebugTree.timeClockType,
    List<String> logLevels = DebugTree.defaultLevels,
    this.maxLineSize = 800,
  }) : super(printTimeType: printTimeType, logLevels: logLevels);

  /// Creates elapsed time Debug Tree compatible with Android.
  factory DebugBufferTree.elapsed(
      {List<String> logLevels = DebugTree.defaultLevels}) {
    return DebugBufferTree(
        logLevels: logLevels, printTimeType: DebugTree.timeElapsedType);
  }

  /// prints log lines breaking them into multiple lines if its too long.
  /// src: https://github.com/flutter/flutter/issues/22665#issuecomment-458186456
  @override
  void printLog(String logLine, {String level}) {
    if (maxLineSize == -1) {
      debugPrint(logLine);
    } else {
      final pattern = RegExp('.{1,$maxLineSize}');

      pattern
          .allMatches(logLine)
          .forEach((match) => debugPrint(match.group(0)));
    }
  }
}
