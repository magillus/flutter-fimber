library fimber;

import 'package:fimber/colorize.dart';
import 'package:fimber/file_log.dart';

export 'package:fimber/data_size.dart';
export 'package:fimber/file_log.dart';
export 'package:fimber/file_log.dart';

/// Main static Fimber logging.
class Fimber {
  static List<String> _muteLevels = [];

  static v(String msg, {dynamic ex, StackTrace stacktrace}) {
    log("V", msg, ex: ex, stacktrace: stacktrace);
  }

  static d(String msg, {dynamic ex, StackTrace stacktrace}) {
    log("D", msg, ex: ex, stacktrace: stacktrace);
  }

  static i(String msg, {dynamic ex, StackTrace stacktrace}) {
    log("I", msg, ex: ex, stacktrace: stacktrace);
  }

  static w(String msg, {dynamic ex, StackTrace stacktrace}) {
    log("W", msg, ex: ex, stacktrace: stacktrace);
  }

  static e(String msg, {dynamic ex, StackTrace stacktrace}) {
    log("E", msg, ex: ex, stacktrace: stacktrace);
  }

  static mute(String level) {
    _muteLevels.add(level);
  }

  static unmute(String level) {
    _muteLevels.remove(level);
  }

  static log(String level, String msg,
      {String tag, dynamic ex, StackTrace stacktrace}) {
    if (_muteLevels.contains(level)) {
      return; // skip logging if muted.
    }

    _trees[level]?.forEach((logger) =>
        logger.log(level, msg, tag: tag, ex: ex, stacktrace: stacktrace));
  }

  /// Plant a tree - the source that will receive log messages.
  static plantTree(LogTree tree) {
    tree.getLevels().forEach((level) {
      var logList = _trees[level];
      if (logList == null) {
        logList = List<LogTree>();
        _trees[level] = logList;
      }
      logList.add(tree);
    });
  }

  static unplantTree(LogTree tree) {
    if (tree != null && tree is CloseableTree) {
      (tree as CloseableTree).close();
    }
    _trees.forEach((level, levelTrees) {
      levelTrees.remove(tree);
    });
  }

  /// Clear all trees from Fimber.
  static clearAll() {
    // unplant each tree
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

  static Map<String, List<LogTree>> _trees = new Map<String, List<LogTree>>();

  /// Creates auto tag and logger, then executes the code block with a logger to use.
  /// Limiting number of 'stacktrace' based tag generation inside the block.
  static dynamic block(RunWithLog block) {
    return withTag(LogTree.getTag(stackIndex: 2), block);
  }

  /// Creates logger with tag, then executes the code block with a logger to use.
  /// Removing need of tag generation.
  static dynamic withTag(String tag, RunWithLog block) {
    var logger = FimberLog(tag);
    return block(logger);
  }
}

typedef RunWithLog = dynamic Function(FimberLog log);

/// Debug log tree. Tag generation included
class DebugTree extends LogTree {
  static const List<String> DEFAULT = ["D", "I", "W", "E"];
  static const int TIME_ELAPSED = 0;
  static const int TIME_CLOCK = 1;
  static final Map<String, ColorizeStyled> _defaultColorizeMap = {
    "V": ColorizeStyled([AnsiStyle.foreground(AnsiColor.BLUE)]),
    "D": ColorizeStyled([AnsiStyle.foreground(AnsiColor.GREEN)]),
    "W": ColorizeStyled([
      AnsiStyle.foreground(AnsiColor.YELLOW),
      AnsiStyle.background(AnsiColor.BLACK)
    ]),
    "E": ColorizeStyled([
      AnsiStyle.bright(AnsiColor.WHITE),
      AnsiStyle.background(AnsiColor.RED)
    ])
  };
  List<String> logLevels;
  final int printTimeType;
  Stopwatch _elapsedTimeStopwatch;
  Map<String, ColorizeStyled> colorizeMap = {};

  DebugTree(
      {this.printTimeType = TIME_CLOCK, this.logLevels = DEFAULT, bool useColors = false}) {
    if (printTimeType == TIME_ELAPSED) {
      _elapsedTimeStopwatch = Stopwatch();
      _elapsedTimeStopwatch.start();
    }
    if (useColors) {
      colorizeMap = _defaultColorizeMap;
    }
  }

  factory DebugTree.elapsed(
      {List<String> logLevels = DEFAULT, bool useColors = false}) {
    return DebugTree(logLevels: logLevels,
        printTimeType: TIME_ELAPSED,
        useColors: useColors);
  }

  @override
  log(String level, String msg,
      {String tag, dynamic ex, StackTrace stacktrace}) {
    var logTag = tag ?? LogTree.getTag();
    if (ex != null) {
      var tmpStacktrace =
          stacktrace?.toString()?.split('\n') ?? LogTree.getStacktrace();
      var stackTraceMessage =
      tmpStacktrace.map((stackLine) => "\t$stackLine").join("\n");
      printLog("$level\t$logTag:\t $msg \n${ex.toString()}\n$stackTraceMessage",
          level: level);
    } else {
      printLog("$level\t$logTag:\t $msg", level: level);
    }
  }

  /// Method to overload printing to output stream the formatted logline
  /// Adds handing of time
  printLog(String logLine, {String level}) {
    String printableLine = logLine;
    if (printTimeType != null) {
      if (printTimeType == TIME_ELAPSED) {
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

  log(String level, String msg,
      {String tag, dynamic ex, StackTrace stacktrace});

  List<String> getLevels();

  /// Gets tag with $stackIndex - how many steps in stacktrace should be taken to grab log call.
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

  /// Gets tag with $stackIndex - how many steps in stacktrace should be taken to grab log call.
  static List<String> getStacktrace({int stackIndex = 6}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    return stackTraceList.sublist(stackIndex);
  }
}

/// Stand alone logger with custom tag defined.
class FimberLog {
  String tag;

  /// Creates FimberLog for a tag.
  FimberLog(this.tag);

  v(String msg, {dynamic ex, StackTrace stacktrace}) {
    _log("V", tag, msg, ex: ex, stacktrace: stacktrace);
  }

  d(String msg, {dynamic ex, StackTrace stacktrace}) {
    _log("D", tag, msg, ex: ex, stacktrace: stacktrace);
  }

  i(String msg, {dynamic ex, StackTrace stacktrace}) {
    _log("I", tag, msg, ex: ex, stacktrace: stacktrace);
  }

  w(String msg, {dynamic ex, StackTrace stacktrace}) {
    _log("W", tag, msg, ex: ex, stacktrace: stacktrace);
  }

  e(String msg, {dynamic ex, StackTrace stacktrace}) {
    _log("E", tag, msg, ex: ex, stacktrace: stacktrace);
  }

  _log(String level, String tag, String msg,
      {dynamic ex, StackTrace stacktrace}) {
    Fimber.log(level, msg, tag: tag, ex: ex, stacktrace: stacktrace);
  }
}
