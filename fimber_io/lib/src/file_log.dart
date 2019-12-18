import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:fimber/colorize.dart';
import 'package:fimber/filename_format.dart';
import 'package:fimber/fimber.dart';

/// File based logging output tree.
/// This tree if planted will post short formatted (elapsed time and message)
/// output into file specified in constructor.
/// Note: Mostly for testing right now
class FimberFileTree extends CustomFormatTree with CloseableTree {
  /// Output current log file name.
  String outputFileName;

  /// Interval for buffer write to file. In milliseconds
  static const fileBufferFlushInterval = 500;

  /// Size limit (bytes) in temporary buffer.
  static const bufferSizeLimit = 1024; //1kB

  int _bufferSize = 0;
  List<String> _logBuffer = [];
  StreamSubscription<List<String>> _bufferWriteInterval;
  int _maxBufferSize = bufferSizeLimit;

  /// Creates Instance of FimberFileTree
  /// with optional [logFormat] from [CustomFormatTree] predicates.
  /// Takes optional [maxBufferSize] (default 1kB) and
  /// optional [bufferWriteInterval] in milliseconds.
  FimberFileTree(this.outputFileName,
      {logLevels = CustomFormatTree.defaultLevels,
      logFormat = "${CustomFormatTree.timeStampToken}"
          "\t${CustomFormatTree.messageToken}",
      int maxBufferSize = bufferSizeLimit,
      int bufferWriteInterval = fileBufferFlushInterval})
      : super(logLevels: logLevels, logFormat: logFormat) {
    _maxBufferSize = maxBufferSize;
    _bufferWriteInterval =
        Stream.periodic(Duration(milliseconds: bufferWriteInterval), (i) {
      // group calls
      var dumpBuffer = _logBuffer;
      _logBuffer = [];
      _bufferSize = 0;
      return dumpBuffer;
    }).listen((newLines) async {
      _flushBuffer(newLines);
    });
  }

  void _checkSizeForFlush() {
    if (_bufferSize > _maxBufferSize) {
      var dumpBuffer = _logBuffer;
      _logBuffer = [];
      _bufferSize = 0;
      Future.microtask(() {
        _flushBuffer(dumpBuffer);
      });
    }
  }

  _flushBuffer(List<String> buffer) async {
    if (buffer.length > 0) {
      IOSink logSink;
      try {
        if (outputFileName != null) {
          // check if file's directory exists
          final parentDir = File(outputFileName).parent;
          if (!parentDir.existsSync()) {
            parentDir.createSync(recursive: true);
          }
          logSink =
              File(outputFileName).openWrite(mode: FileMode.writeOnlyAppend);
          for (var newLine in buffer) {
            logSink.writeln(newLine);
          }
          await logSink.flush();
        }
      } finally {
        logSink?.close();
      }
    }
  }

  /// Creates Fimber File tree with time tracking as elapsed
  /// from start of the process.
  factory FimberFileTree.elapsed(String fileName,
      {List<String> logLevels = CustomFormatTree.defaultLevels}) {
    return FimberFileTree(fileName,
        logFormat: "${CustomFormatTree.timeElapsedToken}"
            "\t${CustomFormatTree.messageToken}");
  }

  @override
  void printLine(String line, {String level}) {
    if (_colorizeMap[level] != null) {
      _logBuffer.add(_colorizeMap[level].wrap(line));
    } else {
      _logBuffer.add(line);
    }
    _bufferSize += line.length;
    _checkSizeForFlush();
  }

  @override
  void close() {
    _bufferWriteInterval?.cancel();
    _bufferWriteInterval = null;
  }
}

/// SizeRolling file tree.
/// It will create new log file with an index every time current
/// one reach [maxDataSize]
class SizeRollingFileTree extends RollingFileTree {
  /// Maximum size allowed for the log file before rolls to new.
  DataSize maxDataSize;

  /// Filename prefix - can contain path to directory where logs would be saved.
  /// by default "log_"
  String filenamePrefix;

  /// Filename postfix, by default ".txt".
  String filenamePostfix;

  int _fileIndex = 0;

  /// Creates instance of SizeRollingFileTree,
  /// which based on defined [maxDataSize] size of current log file
  /// will create new log file.
  SizeRollingFileTree(this.maxDataSize,
      {logFormat = CustomFormatTree.defaultFormat,
      this.filenamePrefix = "log_",
      this.filenamePostfix = ".txt",
      logLevels = CustomFormatTree.defaultLevels})
      : super(logFormat: logFormat, logLevels: logLevels) {
    detectFileIndex();
  }

  /// Detects file index based on same [filenamePrefix] and [filenamePostfix]
  /// and based on current files in the log directory.
  void detectFileIndex() {
    var rootDir = Directory(filenamePrefix);
    if (filenamePrefix.contains(Platform.pathSeparator)) {
      rootDir = Directory(filenamePrefix.substring(
          0, filenamePrefix.lastIndexOf(Platform.pathSeparator)));
    }
    var logListIndexes = rootDir
        .listSync()
        .map((fe) => getLogIndex(fe.path))
        .where((i) => i >= 0)
        .toList();
    logListIndexes.sort();
    print("log list indexes: $logListIndexes");
    if (logListIndexes.length > 0) {
      var max = logListIndexes.last;
      _fileIndex = max;
      if (_isFileOverSize(_logFile(max))) {
        rollToNextFile();
      } else {
        outputFileName = _currentFile();
        print("Logfile is $outputFileName");
      }
    } else {
      _fileIndex = 0;
      rollToNextFile();
    }
  }

  String _currentFile() {
    return _logFile(_fileIndex);
  }

  String _logFile(int index) {
    return filenamePrefix + index.toString() + filenamePostfix;
  }

  @override
  void rollToNextFile() {
    _fileIndex = _fileIndex + 1;
    outputFileName = _currentFile();
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
  FutureOr<bool> shouldRollNextFile() {
    var file = File(_currentFile());
    if (file.existsSync()) {
      return file.lengthSync() > maxDataSize.realSize;
    } else {
      return false;
    }
  }

  RegExp get _fileRegExp => RegExp(
      "${filenamePrefix.replaceAll("\\", "\\\\")}([0-9]+)?$filenamePostfix");

  /// Gets log index from a file path.
  int getLogIndex(String filePath) {
    if (isLogFile(filePath)) {
      return _fileRegExp.allMatches(filePath).map((match) {
        if (match != null && match.groupCount > 0) {
          return int.parse(match.group(1));
        } else {
          return -1;
        }
      }).firstWhere((i) => i != null, orElse: () => null);
    } else {
      return -1;
    }
  }

  /// Checks if this is matching log file.
  bool isLogFile(String filePath) {
    return _fileRegExp.allMatches(filePath).map((match) {
      if (match != null && match.groupCount > 0) {
        return true;
      } else {
        return false;
      }
    }).lastWhere((e) => e != null, orElse: () => false);
  }
}

/// Time base rolling file tree.
/// It will use time span to roll logging to next file.
class TimedRollingFileTree extends RollingFileTree {
  /// Number of seconds in an hour
  static const int hourlyTime = 60 * 60;

  /// Number of seconds in a day
  static const int dailyTime = 24 * hourlyTime;

  /// Number of seconds in a week
  static const int weeklyTime = 7 * dailyTime;

  /// File rolling based on this time span. Default 1h
  int timeSpan = hourlyTime;

  /// Maximum of number of files in history.
  int maxHistoryFiles;
  DateTime _currentFileDate;

  /// Generated filename prefix, supports path to the file.
  String filenamePrefix;

  /// Generated filename postfix
  String filenamePostfix;

  /// Log filename formatter see: [LogFileNameFormatter]
  LogFileNameFormatter fileNameFormatter;

  /// Creates Time based rolling file tree.
  /// It allows to define time span when this
  TimedRollingFileTree(
      {this.timeSpan = TimedRollingFileTree.dailyTime,
      logFormat = CustomFormatTree.defaultFormat,
      this.filenamePrefix = "log_",
      this.filenamePostfix = ".txt",
      logLevels = CustomFormatTree.defaultLevels}) {
    fileNameFormatter = LogFileNameFormatter.full(
        prefix: filenamePrefix, postfix: filenamePostfix);
    rollToNextFile();
  }

  @override
  void rollToNextFile() {
    var localNow = DateTime.now();
    _currentFileDate ??= localNow;
    if (fileNameFormatter == null) {
      var diffSeconds = _currentFileDate.difference(localNow).inSeconds;
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
    // little math to get NOW time based on timespan interval.
    var nowFlooredToTimeSpan = DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch -
            (now.millisecondsSinceEpoch % (timeSpan * 1000)).toInt());
    if (fileNameFormatter.format(nowFlooredToTimeSpan) !=
        fileNameFormatter.format(_currentFileDate)) {
      _currentFileDate = nowFlooredToTimeSpan;
      return true;
    }
    return false;
  }
}

/// Class for defining rolling file tree.
/// This class handles file logging and printing lines,
/// also provides abstract methods to check if the file should rotate.
abstract class RollingFileTree extends FimberFileTree {
  /// Path format for log file.
  String pathFormat;

  /// Creates RollingFileTree with log format and levels as optional parameters.
  RollingFileTree(
      {logFormat = CustomFormatTree.defaultFormat,
      logLevels = CustomFormatTree.defaultLevels})
      : super('.', logFormat: logFormat, logLevels: logLevels);

  /// Return true if log file should rotate to new.
  FutureOr<bool> shouldRollNextFile();

  /// Roll to new file
  void rollToNextFile();

  @override
  void printLine(String line, {String level}) async {
    if (await shouldRollNextFile()) {
      await rollToNextFile();
    }
    super.printLine(line, level: level);
  }
}

/// Custom format tree. Tag generation included
/// allows to define tokens in format,
/// which will be replaced with a value for each log line.
class CustomFormatTree extends LogTree {
  /// List of default levels for debug logging
  static const List<String> defaultLevels = ["D", "I", "W", "E"];

  /// Format token for time stamp
  static const String timeStampToken = "{TIME_STAMP}";

  /// Format token for time elapsed
  static const String timeElapsedToken = "{TIME_ELAPSED}";

  /// Format token for log level character
  static const String levelToken = "{LEVEL}";

  /// Format token for log tag
  static const String tagToken = "{TAG}";

  /// Format token for main log message
  static const String messageToken = "{MESSAGE}";

  /// Format token for exception message
  static const String exceptionMsgToken = "{EX_MSG}";

  /// Format token for exception's stacktrace
  static const String exceptionStackToken = "{EX_STACK}";

  /// Default format for timestamp based log message.
  static const String defaultFormat =
      "$timeStampToken\t$levelToken $tagToken: $messageToken";

  /// Flag elapsed time in format
  static const int timeElapsedFlag = 1;

  /// Flag clock time in format
  static const int timeClockFlag = 2;

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

  List<String> _logLevels;
  int _printTimeFlag;
  Stopwatch _elapsedTimeStopwatch;

  /// Log line format style.
  String logFormat;
  bool _useColors;
  Map<String, ColorizeStyle> _colorizeMap = {};

  /// Creates custom format logging tree
  CustomFormatTree(
      {this.logFormat = defaultFormat,
      List<String> logLevels = defaultLevels,
      bool useColors = false}) {
    _logLevels = logLevels;
    _useColors = useColors;
    if (_useColors) {
      _colorizeMap = _defaultColorizeMap;
    }
    _printTimeFlag = 0;
    if (logFormat.contains(timeStampToken)) {
      _printTimeFlag |= timeClockFlag;
    }
    if (logFormat.contains(timeElapsedToken)) {
      _printTimeFlag |= timeElapsedFlag;
    }
    if (_printTimeFlag & timeElapsedFlag > 0) {
      _elapsedTimeStopwatch = Stopwatch();
      _elapsedTimeStopwatch.start();
    }
  }

  @override

  /// Logs a message with level/tag and optional stacktrace or exception.
  void log(String level, String msg,
      {String tag, dynamic ex, StackTrace stacktrace}) {
    var logTag = tag ?? LogTree.getTag();

    if (logFormat != null) {
      _printFormattedLog(level, msg, logTag, ex, stacktrace);
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

  /// Prints log line with optional log level.
  void printLine(String line, {String level}) {
    if (_colorizeMap[level] != null) {
      print(_colorizeMap[level].wrap(line));
    } else {
      print(line);
    }
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

    var logLine = _replaceAllSafe(logFormat, timeStampToken, date);
    logLine = _replaceAllSafe(logLine, timeElapsedToken, elapsed);
    logLine = _replaceAllSafe(logLine, levelToken, level);
    logLine = _replaceAllSafe(logLine, messageToken, msg);
    logLine = _replaceAllSafe(logLine, exceptionMsgToken, exMsg);
    logLine = _replaceAllSafe(logLine, exceptionStackToken, stacktrace);
    logLine = _replaceAllSafe(logLine, tagToken, tag);
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
  void printLog(String logLine, {String level}) {
    if (_printTimeFlag != null) {
      if (_printTimeFlag & timeElapsedFlag > 0) {
        var timeElapsed = _elapsedTimeStopwatch.elapsed.toString();
        printLine("$timeElapsed\t$logLine", level: level);
      } else {
        var date = DateTime.now().toIso8601String();
        printLine("$date\t$logLine", level: level);
      }
    } else {
      printLine(logLine, level: level);
    }
  }

  @override
  List<String> getLevels() {
    return _logLevels;
  }
}

/// Abstract class to mark implementor as Closable Tree
// ignore: one_member_abstracts
abstract class CloseableTree {
  /// Closes a tree,
  /// use it to flush buffer/caches or close any resource.
  void close();
}
