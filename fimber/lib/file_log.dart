import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:fimber/filename_format.dart';
import 'package:fimber/fimber.dart';

/// File based logging output tree.
/// This tree if planted will post short formatted (elapsed time and message) output into file specified in constructor.
/// Note: Mostly for testing right now
class FimberFileTree extends CustomFormatTree {
  String outputFileName;

  FimberFileTree(this.outputFileName,
      {logLevels = CustomFormatTree.DEFAULT,
        logFormat =
        "${CustomFormatTree.TIME_STAMP_TOKEN}\t${CustomFormatTree
            .MESSAGE_TOKEN}"})
      : super(logLevels: logLevels, logFormat: logFormat);

  factory FimberFileTree.elapsed(String fileName,
      {List<String> logLevels = CustomFormatTree.DEFAULT}) {
    return FimberFileTree(fileName,
        logFormat:
        "${CustomFormatTree.TIME_ELAPSED_TOKEN}\t${CustomFormatTree
            .MESSAGE_TOKEN}");
  }

  @override
  void printLine(String line) {
    IOSink fileSink;
    try {
      if (outputFileName != null) {
        fileSink =
            File(outputFileName).openWrite(mode: FileMode.writeOnlyAppend);
        fileSink.writeln(line);
      }
    } catch (eio) {
      print("Error writing log line to file: $eio");
    } finally {
      fileSink?.close();
    }
  }
}

/// SizeRolling file tree
class SizeRollingFileTree extends RollingFileTree {
  DataSize maxDataSize;

  String filenamePrefix;
  String filenamePostfix;
  FutureOr<int> fileIndex = 0;

  SizeRollingFileTree(this.maxDataSize,
      {logFormat = CustomFormatTree.DEFAULT_FORMAT,
        this.filenamePrefix = "log_",
        this.filenamePostfix = ".txt",
        logLevels = CustomFormatTree.DEFAULT})
      : super(logFormat: logFormat, logLevels: logLevels) {
    detectFileIndex();
  }

  detectFileIndex() async {
    var logListIndexes = await Directory.current
        .list()
        .map((fe) => getLogIndex(fe.path))
        .where((i) => i != null)
        .toList();
    logListIndexes.sort();
    print("log list indexes: $logListIndexes");
    if (logListIndexes.length > 0) {
      var max = logListIndexes.last;
      fileIndex = max;
      if (_isFileOverSize(_logFile(max))) {
        rollToNextFile();
      }
    } else {
      fileIndex = 0;
      rollToNextFile();
    }
  }

  FutureOr<String> _currentFile() async {
    return _logFile(await fileIndex);
  }

  String _logFile(int index) {
    return "${filenamePrefix}${index}$filenamePostfix";
  }

  @override
  void rollToNextFile() async {
    fileIndex = Future.sync(() async {
      return (await fileIndex) + 1;
    });
    outputFileName = await _currentFile();
    if (File(outputFileName).existsSync()) {
      File(outputFileName).deleteSync();
    }
  }

  bool _isFileOverSize(String path) {
    var file = File(path);
    if (file.existsSync()) {
      return File(path).lengthSync() > maxDataSize.realSize;
    } else {
      return false;
    }
  }

  @override
  Future<bool> shouldRollNextFile() async {
    var file = File(await _currentFile());
    if (file.existsSync()) {
      return file.lengthSync() > maxDataSize.realSize;
    } else
      return false;
  }

  RegExp get fileRegExp =>
      RegExp("${filenamePrefix}([0-9]+)?${filenamePostfix}");

  int getLogIndex(String filePath) {
    if (isLogFile(filePath)) {
      return fileRegExp.allMatches(filePath).map((match) {
        if (match != null && match.groupCount > 0) {
          return int.parse(match.group(1));
        } else {
          return null;
        }
      }).firstWhere((i) => i != null, orElse: () => null);
    } else {
      return null;
    }
  }

  bool isLogFile(String filePath) {
    return fileRegExp.allMatches(filePath).map((match) {
      if (match != null && match.groupCount > 0) {
        return true;
      } else {
        return false;
      }
    }).lastWhere((e) => e != null, orElse: () => false);
  }
}

class TimedRollingFileTree extends RollingFileTree {
  static const int HOURLY_TIME = 60 * 60;
  static const int DAILY_TIME = 24 * HOURLY_TIME;
  static const int WEEKLY_TIME = 7 * DAILY_TIME;

  int timeSpan = HOURLY_TIME;
  int maxHistoryFiles;
  DateTime _currentFileDate;
  String filenamePrefix;
  String filenamePostfix;

  LogFileNameFormatter fileNameFormatter;

  TimedRollingFileTree({this.timeSpan = TimedRollingFileTree.DAILY_TIME,
    logFormat = CustomFormatTree.DEFAULT_FORMAT,
    this.filenamePrefix = "log_",
    this.filenamePostfix = ".txt",
    logLevels = CustomFormatTree.DEFAULT}) {
    fileNameFormatter = LogFileNameFormatter.full(
        prefix: filenamePrefix, postfix: filenamePostfix);
    rollToNextFile();
  }

  @override
  void rollToNextFile() {
    if (_currentFileDate == null) {
      _currentFileDate = DateTime.now();
    }
    if (fileNameFormatter == null) {
      var diffSeconds = _currentFileDate
          .difference(DateTime.now())
          .inSeconds;
      if (diffSeconds > timeSpan) {
        fileNameFormatter = LogFileNameFormatter.full(
            prefix: filenamePrefix, postfix: filenamePostfix);
      }
    }
    outputFileName = fileNameFormatter.format(_currentFileDate);
  }

  @override
  bool shouldRollNextFile() {
    var now = DateTime.now();
    if (fileNameFormatter.format(now) !=
        fileNameFormatter.format(_currentFileDate)) {
      _currentFileDate = now;
      return true;
    }
    return false;
  }
}

abstract class RollingFileTree extends FimberFileTree {
  String pathFormat;

  RollingFileTree({logFormat = CustomFormatTree.DEFAULT_FORMAT,
    logLevels = CustomFormatTree.DEFAULT})
      : super(null, logFormat: logFormat, logLevels: logLevels) {}

  FutureOr<bool> shouldRollNextFile();

  rollToNextFile();

  @override
  void printLine(String line) async {
    if (await shouldRollNextFile()) {
      await rollToNextFile();
    }
    super.printLine(line);
  }
}

/// Custom format tree. Tag generation included
/// allows to define tokens in format, which will be replaced with a value for each log line.
class CustomFormatTree extends LogTree {
  static const List<String> DEFAULT = ["D", "I", "W", "E"];

  /// Format token for time stamp
  static const String TIME_STAMP_TOKEN = "{TIME_STAMP}";

  /// Format token for time elapsed
  static const String TIME_ELAPSED_TOKEN = "{TIME_ELAPSED}";

  /// Format token for log level character
  static const String LEVEL_TOKEN = "{LEVEL}";

  /// Format token for log tag
  static const String TAG_TOKEN = "{TAG}";

  /// Format token for main log message
  static const String MESSAGE_TOKEN = "{MESSAGE}";

  /// Format token for exception message
  static const String EXCEPTION_MSG_TOKEN = "{EX_MSG}";

  /// Format token for exception's stackstrace
  static const String EXCEPTION_STACK_TOKEN = "{EX_STACK}";

  static const String DEFAULT_FORMAT =
      "$TIME_STAMP_TOKEN\t$LEVEL_TOKEN\t$TAG_TOKEN:\t $MESSAGE_TOKEN";

  /// Flag elapsed time in format
  static const int TIME_ELAPSED = 1;

  /// Flag clodk time in format
  static const int TIME_CLOCK = 2;
  List<String> logLevels;
  int printTimeFlag;
  Stopwatch _elapsedTimeStopwatch;
  String logFormat;

  CustomFormatTree(
      {this.logFormat = DEFAULT_FORMAT, this.logLevels = DEFAULT}) {
    printTimeFlag = 0;
    if (logFormat.contains(TIME_STAMP_TOKEN)) {
      printTimeFlag |= TIME_CLOCK;
    }
    if (logFormat.contains(TIME_ELAPSED_TOKEN)) {
      printTimeFlag |= TIME_ELAPSED;
    }
    if (printTimeFlag & TIME_ELAPSED > 0) {
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

  void _printFormattedLog(String level, String msg, String tag, ex,
      StackTrace stacktrace) {
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
    if (printTimeFlag != null) {
      if (printTimeFlag & TIME_ELAPSED > 0) {
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
