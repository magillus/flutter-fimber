// ignore: avoid_classes_with_only_static_members
import 'colorize.dart';

/// Main static Fimber logging.
// ignore: avoid_classes_with_only_static_members
class Fimber {
  static final List<String> _muteLevels = [];

  /// Logs VERBOSE level [message]
  /// with optional exception and stacktrace
  static void v(String message, {dynamic ex, StackTrace stacktrace}) {
    log("V", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs DEBUG level [message]
  /// with optional exception and stacktrace
  static void d(String message, {dynamic ex, StackTrace stacktrace}) {
    log("D", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs INFO level [message]
  /// with optional exception and stacktrace
  static void i(String message, {dynamic ex, StackTrace stacktrace}) {
    log("I", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs WARNING level [message]
  /// with optional exception and stacktrace
  static void w(String message, {dynamic ex, StackTrace stacktrace}) {
    log("W", message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs ERROR level [message]
  /// with optional exception and stacktrace
  static void e(String message, {dynamic ex, StackTrace stacktrace}) {
    log("E", message, ex: ex, stacktrace: stacktrace);
  }

  /// Mute a log [level] for logging.
  /// Any log entries with the muted log level will be not printed.
  static void mute(String level) {
    _muteLevels.add(level);
  }

  /// UnMutes a log [level] for logging.
  /// Any log entries with the muted log level will be not printed.
  static void unmute(String level) {
    _muteLevels.remove(level);
  }

  /// Logs a [message] with provided [level]
  /// and optional [tag], [ex] and [stacktrace]
  static void log(String level, String message,
      {String tag, dynamic ex, StackTrace stacktrace}) {
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
    }
    ;
  }

  /// Un-plants a tree from
  static void unplantTree(LogTree tree) {
    if (tree != null && tree is CloseableTree) {
      (tree as CloseableTree).close();
    }
    _trees.forEach((level, levelTrees) {
      levelTrees.remove(tree);
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
  Stopwatch _elapsedTimeStopwatch;

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
      _elapsedTimeStopwatch = Stopwatch();
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
      {String tag, dynamic ex, StackTrace stacktrace}) {
    var logTag = tag ?? LogTree.getTag();
    if (ex != null) {
      var tmpStacktrace =
          stacktrace?.toString()?.split('\n') ?? LogTree.getStacktrace();
      var stackTraceMessage =
          tmpStacktrace.map((stackLine) => "\t$stackLine").join("\n");
      printLog(
          "$level\t$logTag:\t $message \n"
          "${ex.toString()}\n$stackTraceMessage",
          level: level);
    } else {
      printLog("$level\t$logTag:\t $message", level: level);
    }
  }

  /// Method to overload printing to output stream the formatted [logLine]
  /// Adds handing of time
  void printLog(String logLine, {String level}) {
    var printableLine = logLine;
    if (printTimeType != null) {
      if (printTimeType == timeElapsedType) {
        var timeElapsed = _elapsedTimeStopwatch.elapsed.toString();
        printableLine = "$timeElapsed\t$logLine";
      } else {
        var date = DateTime.now().toIso8601String();
        printableLine = "$date\t$logLine";
      }
    }
    if (colorizeMap[level] != null) {
      print(colorizeMap[level].wrap(printableLine));
    } else {
      print(printableLine);
    }
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }
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

  /// Gets tag with [stackIndex],
  /// how many steps in stacktrace should be taken to grab log call.
  static String getTag({int stackIndex = 4}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    if (stackTraceList.length > stackIndex) {
      var lineChunks =
          stackTraceList[stackIndex].replaceAll("<anonymous closure>", "<ac>");
      if (lineChunks.length > 6) {
        var lineParts = lineChunks.split(' ');
        if (lineParts.length > 8 && lineParts[6] == 'new') {
          // constructor logging
          return "${lineParts[6]} ${lineParts[7]}";
        } else if (lineParts.length > 6) {
          return lineParts[6] ?? _defaultTag; // need better error handling
        } else {
          return _defaultTag;
        }
      } else {
        return _defaultTag;
      }
    } else {
      return _defaultTag; //default
    }
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
  void v(String message, {dynamic ex, StackTrace stacktrace}) {
    _log("V", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs DEBUG level [message]
  /// with optional exception and stacktrace
  void d(String message, {dynamic ex, StackTrace stacktrace}) {
    _log("D", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs INFO level [message]
  /// with optional exception and stacktrace
  void i(String message, {dynamic ex, StackTrace stacktrace}) {
    _log("I", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs WARNING level [message]
  /// with optional exception and stacktrace
  void w(String message, {dynamic ex, StackTrace stacktrace}) {
    _log("W", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs ERROR level [message]
  /// with optional exception and stacktrace
  void e(String message, {dynamic ex, StackTrace stacktrace}) {
    _log("E", tag, message, ex: ex, stacktrace: stacktrace);
  }

  /// Logs [message] with [tag] and [level]
  /// with optional exception and [stacktrace]
  _log(String level, String tag, String message,
      {dynamic ex, StackTrace stacktrace}) {
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
    if (colorizeMap[level] != null) {
      print(colorizeMap[level].wrap(line));
    } else {
      print(line);
    }
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
