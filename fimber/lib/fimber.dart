library fimber;

import 'package:fimber/colorize.dart';
import 'package:fimber/file_log.dart';

export 'package:fimber/data_size.dart';
export 'package:fimber/file_log.dart';
export 'package:fimber/file_log.dart';

// ignore: avoid_classes_with_only_static_members
/// Main static Fimber logging.
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
    for (var logger in _trees[level]) {
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
  DebugTree({this.printTimeType = timeClockType,
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
  static String getTag({int stackIndex = 6}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    if (stackTraceList.length > stackIndex) {
      var lineChunks =
      stackTraceList[stackIndex].replaceAll("<anonymous closure>", "<ac>");
      if (lineChunks.length > 6) {
        var lineParts = lineChunks.split(' ');
        if (lineParts.length > 8 && lineParts[6] == 'new') {
          // constructor logging
          return "${lineParts[6]} ${lineParts[7]}";
        } else {
          return lineParts[6] ?? _defaultTag; // need better error handling
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
