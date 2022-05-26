// ignore: avoid_classes_with_only_static_members
import 'colorize.dart';

// ignore: avoid_classes_with_only_static_members
/// Main static Fimber logging.
class Fimber {
  static final List<String> _muteLevels = [];

  /// Logs VERBOSE level [message]
  /// with optional exception and stacktrace
  static void v(String message, {dynamic? ex, StackTrace? stacktrace}) {
    log("V", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs DEBUG level [message]
  /// with optional exception and stacktrace
  static void d(String message, {dynamic? ex, StackTrace? stacktrace}) {
    log("D", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs INFO level [message]
  /// with optional exception and stacktrace
  static void i(String message, {dynamic? ex, StackTrace? stacktrace}) {
    log("I", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs WARNING level [message]
  /// with optional exception and stacktrace
  static void w(String message, {dynamic? ex, StackTrace? stacktrace}) {
    log("W", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs ERROR level [message]
  /// with optional exception and stacktrace
  static void e(String message, {dynamic ex, StackTrace? stacktrace}) {
    log("E", message, ex: ex, stacktrace: stacktrace);
  }

  /// Mute a log [level] for logging.
  /// Any log entries with the muted log level will be not printed.
  static void mute(String level) {
    if (!_muteLevels.contains(level)) _muteLevels.add(level);
  }

  /// UnMutes a log [level] for logging.
  /// Any log entries with the muted log level will be not printed.
  static void unmute(String level) {
    _muteLevels.removeWhere((it) => it == level);
  }

  /// Logs a [message] with provided [level]
  /// and optional [tag], [ex] and [stacktrace]
  static void log(String level, String message,
      {String? tag, dynamic? ex, StackTrace? stacktrace}) {
    if (_muteLevels.contains(level)) {
      return; // skip logging if muted.
    }
    var loggersForTree = _trees[level];
    for (var logger in loggersForTree ?? []) {
      logger.log(level, message, tag: tag, ex: ex, stacktrace: stacktrace);
    }
  }

  /// Plant a tree - the source that will receive log messages.
  static void plantTree(LogTree tree) {
    for (var level in tree.getLevels()) {
      var logList = _trees[level];
      if (logList == null) {
        logList = [];
        _trees[level] = logList;
      }
      logList.add(tree);
      if (tree is UnPlantableTree) {
        (tree as UnPlantableTree).planted();
      }
    }
    ;
  }

  /// Un-plants a tree from
  static void unplantTree(LogTree tree) {
    if (tree is CloseableTree) {
      (tree as CloseableTree).close();
    }
    _trees.forEach((level, levelTrees) {
      levelTrees.remove(tree);
      if (tree is UnPlantableTree) {
        (tree as UnPlantableTree).unplanted();
      }
    });
  }

  /// Clear all trees from Fimber.
  static void clearAll() {
    // un-plant each tree
    _trees.values
        .toSet()
        .fold<List<LogTree>>(<LogTree>[], (buildList, newList) {
          buildList.addAll(newList);
          return buildList;
        })
        .toSet()
        .forEach(unplantTree);
    _trees.clear();
  }

  static final Map<String, List<LogTree>> _trees = {};

  /// Creates auto tag and logger, then executes the code block
  /// with a logger to use.
  /// Limiting number of 'stacktrace' based tag generation inside the block.
  static dynamic block(RunWithLog block) {
    return withTag(LogTree.getTag(stackIndex: 2), block);
  }

  /// Creates logger with tag, then executes the code block
  /// with a logger to use.
  /// Removing need of tag generation.
  static dynamic withTag(String tag, RunWithLog block) {
    var logger = FimberLog(tag);
    return block(logger);
  }
}

/// Function that is run with a [FimberLog] as parameter.
/// This saves time for fetching generated Tag from code at time of compilation.
/// Can be used in blocks of code that require logging and speed.
typedef RunWithLog = dynamic Function(FimberLog log);

/// Debug log tree. Tag generation included
class DebugTree extends LogTree {
  /// Default levels for logging a debug.
  static const List<String> defaultLevels = ["D", "I", "W", "E"];

  /// Elapsed time type tracking for logging
  static const int timeElapsedType = 0;

  /// Actual clock time type tracking for logging
  static const int timeClockType = 1;
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

  /// Log levels processed by this [DebugTree]
  List<String> logLevels;

  /// Type of time to print.
  final int printTimeType;
  final Stopwatch _elapsedTimeStopwatch = Stopwatch();

  /// Colors style map, with key as log level and value as [ColorizeStyle]
  /// Visible on supported consoles.
  Map<String, ColorizeStyle> colorizeMap = {};

  /// Creates DebugTree with defaults
  /// or with defined [printTimeType], [logLevels], [useColors]
  DebugTree(
      {this.printTimeType = timeClockType,
      this.logLevels = defaultLevels,
      bool useColors = false}) {
    if (printTimeType == timeElapsedType) {
      _elapsedTimeStopwatch.reset();
      _elapsedTimeStopwatch.start();
    }
    if (useColors) {
      colorizeMap = _defaultColorizeMap;
    }
  }

  /// Creates elapsed time type Debug log tree
  /// with optional [logLevels] and [useColors]
  factory DebugTree.elapsed(
      {List<String> logLevels = defaultLevels, bool useColors = false}) {
    return DebugTree(
        logLevels: logLevels,
        printTimeType: timeElapsedType,
        useColors: useColors);
  }

  /// Logs [message] with [level]
  /// and optional [tag], [ex] (exception, [stacktrace]
  @override
  void log(String level, String message,
      {String? tag, dynamic? ex, StackTrace? stacktrace}) {
    var logTag = tag ?? LogTree.getTag();
    final logLineBuilder = StringBuffer("$level\t$logTag:\t $message");

    if (ex != null) {
      logLineBuilder.write("\n${ex.toString()}");
    }
    if (stacktrace != null) {
      var tmpStacktrace = stacktrace.toString().split('\n');
      var stackTraceMessage =
          tmpStacktrace.map((stackLine) => "\t$stackLine").join("\n");
      logLineBuilder.write("\n$stackTraceMessage");
    }
    printLog(logLineBuilder.toString(), level: level);
  }

  /// Method to overload printing to output stream the formatted [logLine]
  /// Adds handing of time
  void printLog(String logLine, {String? level}) {
    var printableLine = logLine;
    if (printTimeType == timeElapsedType) {
      var timeElapsed = _elapsedTimeStopwatch.elapsed.toString();
      printableLine = "$timeElapsed\t$logLine";
    } else {
      var date = DateTime.now().toIso8601String();
      printableLine = "$date\t$logLine";
    }
    var colorizeTransform = (level != null) ? colorizeMap[level] : null;
    if (colorizeTransform != null) {
      print(colorizeTransform.wrap(printableLine));
    } else {
      print(printableLine);
    }
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }
}

/// Interface for `LogTree` that have some lifecycle with it.
/// Introduces callbacks to plant and unroot events.
abstract class UnPlantableTree {
  /// Called when the tree is planted.
  void planted();

  /// Called when the tree is unrooted.
  void unplanted();
}

/// Log Line Information.
/// Used when extracting tag and attaching log line number value.
class LogLineInfo {
  /// Tag extracted from stacktrace (usually class)
  String tag;

  /// Log file path.
  String? logFilePath;

  /// Line number of the log line.
  int lineNumber;

  /// Character at the log line.
  int characterIndex;

  /// Creates LogLineInfo instance.
  LogLineInfo(
      {required this.tag,
      this.logFilePath,
      this.lineNumber = 0,
      this.characterIndex = 0});
}

/// Interface for LogTree
abstract class LogTree {
  static const String _defaultTag = "Flutter";

  /// Logs [message] with log [level]
  /// and optional [tag], [ex] (exception) [stacktrace]
  void log(String level, String message,
      {String tag, dynamic ex, StackTrace stacktrace});

  /// Gets levels of logging serviced by this [LogTree]
  List<String> getLevels();

  static final _lineInfoMatcher = RegExp(r"\(\w+:(.*\.dart):(\d*)[:(\d*)]");

  /// "#4      main.<anonymous closure>.<anonymous closure> (file:///Users/magillus/Projects/opensource/flutter-fimber/fimber/test/fimber_test.dart:19:14)"
  /// “#4      _MyAppState.build.<anonymous closure> (package:flutter_fimber_example/main.dart:83:26)
  /// “#4      _MyAppState.build (package:flutter_fimber_example/main.dart:83)

  /// Gets [LogLineInfo] with [stackIndex]
  /// which provides data for tag and line of code
  static LogLineInfo getLogLineInfo({int stackIndex = 4}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    if (stackTraceList.length > stackIndex) {
      var stackinfo = stackTraceList[stackIndex];
      var lineParts = _getLineChunks(stackinfo);
      var tag = _defaultTag;
      var lineinfo = '(package:flutter_fimber/error.dart:0:0)';
      if (lineParts.length > 3 && lineParts[1] == 'new') {
        // constructor logging
        tag = "${lineParts[1]} ${lineParts[2]}";
        lineinfo = lineParts[3];
      } else if (lineParts.length > 2) {
        lineinfo = lineParts[2];
        tag = lineParts[1];
      } else if (lineParts.length > 1) {
        tag = lineParts[1];
      }

      final matches = _lineInfoMatcher.allMatches(lineinfo);
      if (matches.isNotEmpty) {
        final match = matches.first;
        if (matches.length == 3) {
          return LogLineInfo(
            tag: tag,
            logFilePath: match.group(1),
            lineNumber: int.tryParse(match.group(2) ?? '-1') ?? -1,
            characterIndex: int.tryParse(match.group(3) ?? '-1') ?? -1,
          );
        }
        return LogLineInfo(
          tag: tag,
          logFilePath: match.group(1),
          lineNumber: int.tryParse(match.group(2) ?? '-1') ?? -1,
        );
      }
    }
    return LogLineInfo(
      tag: _defaultTag,
    );
  }

  /*
  static final _logMatcher =
      RegExp(r"([a-zA-Z\<\>\s\.]*)\s\(\w+:(.*\.dart):(\d*):(\d*)");
  /// Gets [LogLineInfo] with [stackIndex]
  /// which provides data for tag and line of code
  static LogLineInfo getLogLineInfo({int stackIndex = 4}) {
    ///([a-zA-Z\<\>\s\.]*)\s\(file:\/(.*\.dart):(\d*):(\d*)
    /// group 1 = tag
    /// group 2 = filepath
    /// group 3 = line number
    /// group 4 = column
    /// "#4      main.<anonymous closure>.<anonymous closure> (file:///Users/magillus/Projects/opensource/flutter-fimber/fimber/test/fimber_test.dart:19:14)"
    /// “#4      _MyAppState.build.<anonymous closure> (package:flutter_fimber_example/main.dart:83:26)
    /// “#4      _MyAppState.build (package:flutter_fimber_example/main.dart:83)

    var stackTraceList = StackTrace.current.toString().split('\n');
    if (stackTraceList.length > stackIndex) {
      var logline = stackTraceList[stackIndex];
      final matches = _logMatcher.allMatches(logline);

      if (matches.isNotEmpty) {
        final match = matches.first;
        return LogLineInfo(
          tag: match
                  .group(1)
                  ?.trim()
                  .replaceAll("<anonymous closure>", "<ac>") ??
              _defaultTag,
          logFilePath: match.group(2),
          lineNumber: int.tryParse(match.group(3) ?? '-1') ?? -1,
          characterIndex: int.tryParse(match.group(4) ?? '-1') ?? -1,
        );
      } else {
        return LogLineInfo(tag: _defaultTag);
      }
    } else {
      return LogLineInfo(tag: _defaultTag);
    }
  }
  */

  static List<String> _getLineChunks(String stackinfo) {
    var lineChunks = stackinfo.replaceAll("<anonymous closure>", "<ac>");
    if (lineChunks.length > 6) {
      var spaces = RegExp(r' +');
      var lineParts = lineChunks.split(spaces);

      return lineParts;
    }
    return <String>[];
  }

  /// Gets tag with [stackIndex],
  /// how many steps in stacktrace should be taken to grab log call.
  static String getTag({int stackIndex = 4}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    if (stackTraceList.length > stackIndex) {
      var lineParts = _getLineChunks(stackTraceList[stackIndex]);
      if (lineParts.length > 3 && lineParts[1] == 'new') {
        // constructor logging
        return "${lineParts[1]} ${lineParts[2]}";
      } else if (lineParts.length > 1) {
        return lineParts[1];
      }
    }
    return _defaultTag;
  }

  /// Gets tag with [stackIndex]
  /// how many steps in stacktrace should be taken to grab log call.
  static List<String> getStacktrace({int stackIndex = 6}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    return stackTraceList.sublist(stackIndex);
  }
}

/// Stand alone logger with custom tag defined.
class FimberLog {
  /// Log [tag] used in formatted message.
  String tag;

  /// Creates instance of [FimberLog] for a ]tag].
  FimberLog(this.tag);

  /// Logs VERBOSE level [message]
  /// with optional exception and stacktrace
  void v(String message, {dynamic? ex, StackTrace? stacktrace}) {
    _log("V", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs DEBUG level [message]
  /// with optional exception and stacktrace
  void d(String message, {dynamic? ex, StackTrace? stacktrace}) {
    _log("D", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs INFO level [message]
  /// with optional exception and stacktrace
  void i(String message, {dynamic? ex, StackTrace? stacktrace}) {
    _log("I", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs WARNING level [message]
  /// with optional exception and stacktrace
  void w(String message, {dynamic? ex, StackTrace? stacktrace}) {
    _log("W", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs ERROR level [message]
  /// with optional exception and stacktrace
  void e(String message, {dynamic? ex, StackTrace? stacktrace}) {
    _log("E", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs [message] with [tag] and [level]
  /// with optional exception and [stacktrace]
  _log(String level, String tag, String message,
      {dynamic? ex, StackTrace? stacktrace}) {
    Fimber.log(level, message, tag: tag, ex: ex, stacktrace: stacktrace);
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

  /// Format token for file path.
  static const String filePathToken = "{FILE_PATH}";

  /// Format token for file name.
  static const String fileNameToken = "{FILE_NAME}";

  /// Format token for file's line number
  static const String lineNumberToken = "{LINE_NUMBER}";

  /// Format token for character index on the line
  static const String charAtIndexToken = "{CHAR_INDEX}";

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

  List<String> _logLevels = defaultLevels;
  int _printTimeFlag = 0;
  Stopwatch? _elapsedTimeStopwatch;

  /// Log line format style.
  String logFormat = defaultFormat;
  bool _useColors = false;

  bool _printFilePath = false;
  bool _printFileName = false;
  bool _printLineNumber = false;
  bool _printCharIndex = false;

  /// Map of log levels and their colorizing style.
  Map<String, ColorizeStyle> colorizeMap = {};

  /// Creates custom format logging tree
  CustomFormatTree(
      {this.logFormat = defaultFormat,
      List<String> logLevels = defaultLevels,
      bool useColors = false}) {
    _logLevels = logLevels;
    _useColors = useColors;
    if (_useColors) {
      colorizeMap = _defaultColorizeMap;
    }
    if (logFormat.contains(timeStampToken)) {
      _printTimeFlag |= timeClockFlag;
    }
    if (logFormat.contains(timeElapsedToken)) {
      _printTimeFlag |= timeElapsedFlag;
    }
    _printFilePath = logFormat.contains(filePathToken);
    _printLineNumber = logFormat.contains(lineNumberToken);
    _printCharIndex = logFormat.contains(charAtIndexToken);
    _printFileName = logFormat.contains(fileNameToken);
    if (_printTimeFlag & timeElapsedFlag > 0) {
      _elapsedTimeStopwatch = Stopwatch()..start();
    }
  }

  String _extractFileName(String? filePath) {
    if (filePath == null) {
      return '';
    } else {
      if (filePath.lastIndexOf('/') >= 0) {
        return filePath.substring(
            filePath.lastIndexOf('/') + 1, filePath.length);
      } else {
        return filePath;
      }
    }
  }

  @override

  /// Logs a message with level/tag and optional stacktrace or exception.
  void log(String level, String msg,
      {String? tag, dynamic? ex, StackTrace? stacktrace}) {
    LogLineInfo logTag;
    logTag = LogTree.getLogLineInfo();
    if (tag != null) {
      logTag.tag = tag;
    }
    _printFormattedLog(level, msg, logTag, ex, stacktrace);
  }

  /// Prints log line with optional log level.
  void printLine(String line, {String? level}) {
    var colorizeTransform = (level != null) ? colorizeMap[level] : null;
    if (colorizeTransform != null) {
      print(colorizeTransform.wrap(line));
    } else {
      print(line);
    }
  }

  void _printFormattedLog(String level, String msg, LogLineInfo logLineInfo, ex,
      StackTrace? stacktrace) {
    if (ex != null) {
      var tmpStacktrace =
          stacktrace?.toString().split('\n') ?? LogTree.getStacktrace();
      var stackTraceMessage =
          tmpStacktrace.map((stackLine) => "\t$stackLine").join("\n");
      printLine(
          _formatLine(logFormat, level, msg, logLineInfo, "\n${ex.toString()}",
              "\n$stackTraceMessage"),
          level: level);
    } else {
      printLine(_formatLine(logFormat, level, msg, logLineInfo, "", ""),
          level: level);
    }
  }

  String _formatLine(String format, String level, String msg,
      LogLineInfo logLineInfo, String exMsg, String stacktrace) {
    var date = DateTime.now().toIso8601String();
    var elapsed = _elapsedTimeStopwatch?.elapsed.toString() ?? '';

    var logLine = _replaceAllSafe(logFormat, timeStampToken, date);
    logLine = _replaceAllSafe(logLine, timeElapsedToken, elapsed);
    logLine = _replaceAllSafe(logLine, levelToken, level);
    logLine = _replaceAllSafe(logLine, messageToken, msg);
    logLine = _replaceAllSafe(logLine, exceptionMsgToken, exMsg);
    logLine = _replaceAllSafe(logLine, exceptionStackToken, stacktrace);
    logLine = _replaceAllSafe(logLine, tagToken, logLineInfo.tag);
    if (_printFilePath) {
      logLine = _replaceAllSafe(
          logLine, filePathToken, logLineInfo.logFilePath ?? '');
    }
    if (_printFileName) {
      logLine = _replaceAllSafe(
          logLine, fileNameToken, _extractFileName(logLineInfo.logFilePath));
    }
    if (_printLineNumber) {
      logLine = _replaceAllSafe(
          logLine, lineNumberToken, logLineInfo.lineNumber.toString());
    }
    if (_printCharIndex) {
      logLine = _replaceAllSafe(
          logLine, charAtIndexToken, logLineInfo.characterIndex.toString());
    }
    return logLine;
  }

  String _replaceAllSafe(String text, String token, String data) {
    if (text.contains(token)) {
      return text.replaceAll(token, data);
    }
    return text;
  }

  /// Method to overload printing to output stream the formatted logline
  /// Adds handing of time
  void printLog(String logLine, {String? level}) {
    if (_printTimeFlag & timeElapsedFlag > 0) {
      var timeElapsed =
          _elapsedTimeStopwatch?.elapsed.toString() ?? "xx:xx:xxx";
      printLine("$timeElapsed\t$logLine", level: level);
    } else {
      var date = DateTime.now().toIso8601String();
      printLine("$date\t$logLine", level: level);
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
