import 'dart:io';

import 'package:fimber/fimber.dart';

class FimberFileTree extends CustomFormatTree {
  String outputFileName;

  FimberFileTree(
    this.outputFileName, {
    logLevels = CustomFormatTree.DEFAULT,
    printTimeType = CustomFormatTree.TIME_ELAPSED,
  }) : super(
            logLevels: logLevels,
            printTimeType: printTimeType,
            logFormat:
                "${CustomFormatTree.TIME_ELAPSED_TOKEN}\t${CustomFormatTree.MESSAGE_TOKEN}");

  factory FimberFileTree.elapsed(String fileName,
      {List<String> logLevels = CustomFormatTree.DEFAULT}) {
    return FimberFileTree(fileName,
        printTimeType: CustomFormatTree.TIME_ELAPSED);
  }

  @override
  void printLine(String line) {
    File(outputFileName).writeAsString(line);
  }
}

/// Debug log tree. Tag generation included
class CustomFormatTree extends LogTree {
  static const List<String> DEFAULT = ["D", "I", "W", "E"];
  static const String TIME_STAMP_TOKEN = "{TIME_STAMP}";
  static const String TIME_ELAPSED_TOKEN = "{TIME_ELAPSED}";
  static const String LEVEL_TOKEN = "{LEVEL}";
  static const String TAG_TOKEN = "{TAG}";
  static const String MESSAGE_TOKEN = "{MESSAGE}";
  static const String EXCEPTION_MSG_TOKEN = "{EX_MSG}";
  static const String EXCEPTION_STACK_TOKEN = "{EX_STACK}";

  static const String DEFAULT_FORMAT =
      "$TIME_STAMP_TOKEN\t$LEVEL_TOKEN\t$TAG_TOKEN:\t $MESSAGE_TOKEN";

  static const int TIME_ELAPSED = 0;
  static const int TIME_CLOCK = 1;
  List<String> logLevels;
  final int printTimeType;
  Stopwatch _elapsedTimeStopwatch;
  String logFormat;

  CustomFormatTree(
      {this.logFormat = DEFAULT_FORMAT,
      this.printTimeType = TIME_CLOCK,
      this.logLevels = DEFAULT}) {
    if (printTimeType == TIME_ELAPSED) {
      _elapsedTimeStopwatch = Stopwatch();
      _elapsedTimeStopwatch.start();
    }
  }

  @override
  log(String level, String msg,
      {String tag, dynamic ex, StackTrace stacktrace}) {
    var logTag = tag ?? LogTree.getTag();

    if (logFormat != null) {
      _printFormattedLog(level, msg, tag, ex, stacktrace);
      return;
    }
    if (ex != null) {
      var tmpStacktrace =
          stacktrace?.toString()?.split('\n') ?? LogTree.getStacktrace();
      var stackTraceMessage =
          tmpStacktrace.map((stackLine) => "\t$stackLine").join("\n");
      printLog(
          "$level\t$logTag:\t $msg \n${ex.toString()}\n$stackTraceMessage");
    } else {
      printLog("$level\t$logTag:\t $msg");
    }
  }

  void printLine(String line) {
    print(line);
  }

  void _printFormattedLog(
      String level, String msg, String tag, ex, StackTrace stacktrace) {
    if (ex != null) {
      var tmpStacktrace =
          stacktrace?.toString()?.split('\n') ?? LogTree.getStacktrace();
      var stackTraceMessage =
          tmpStacktrace.map((stackLine) => "\t$stackLine").join("\n");
      printLine(_formatLine(logFormat, level, msg, tag, "\n${ex.toString()}",
          "\n$stackTraceMessage"));
    } else {
      printLine(_formatLine(logFormat, level, msg, tag, "", ""));
    }
  }

  String _formatLine(String format, String level, String msg, String tag,
      String exMsg, String stacktrace) {
    var date = DateTime.now().toIso8601String();
    var elapsed = _elapsedTimeStopwatch?.elapsed?.toString() ?? "";

    var logLine = _replaceAllSafe(logFormat, TIME_STAMP_TOKEN, date);
    logLine = _replaceAllSafe(logLine, TIME_ELAPSED_TOKEN, elapsed);
    logLine = _replaceAllSafe(logLine, MESSAGE_TOKEN, msg);
    logLine = _replaceAllSafe(logLine, EXCEPTION_MSG_TOKEN, exMsg);
    logLine = _replaceAllSafe(logLine, EXCEPTION_STACK_TOKEN, stacktrace);
    logLine = _replaceAllSafe(logLine, TAG_TOKEN, tag);
    return logLine;
  }

  String _replaceAllSafe(String text, String token, String data) {
    if (text.contains(token)) {
      return text.replaceAll(token, data ?? "");
    }
    return text;
  }

  /// Method to overload printing to output stream the formatted logline
  /// Adds handing of time
  printLog(String logLine) {
    if (printTimeType != null) {
      if (printTimeType == TIME_ELAPSED) {
        var timeElapsed = _elapsedTimeStopwatch.elapsed.toString();
        printLine("$timeElapsed\t$logLine");
      } else {
        var date = DateTime.now().toIso8601String();
        printLine("$date\t$logLine");
      }
    } else
      printLine(logLine);
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }
}
