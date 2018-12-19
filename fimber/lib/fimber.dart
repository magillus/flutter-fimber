library fimber;

/// Main static Fimber logging.
class Fimber {
  static v(String msg, {dynamic ex}) {
    log("V", msg, ex: ex);
  }

  static d(String msg, {dynamic ex}) {
    log("D", msg, ex: ex);
  }

  static i(String msg, {dynamic ex}) {
    log("I", msg, ex: ex);
  }

  static w(String msg, {dynamic ex}) {
    log("W", msg, ex: ex);
  }

  static e(String msg, {dynamic ex}) {
    log("E", msg, ex: ex);
  }

  static log(String level, String msg, {String tag, dynamic ex}) {
    _trees[level]
        ?.forEach((logger) => logger.log(level, msg, tag: tag, ex: ex));
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
    _trees.forEach((level, levelTrees) {
      levelTrees.remove(tree);
    });
  }

  /// Clear all trees from Fimber.
  static clearAll() {
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
  List<String> logLevels;
  final int printTimeType;
  Stopwatch _elapsedTimeStopwatch;

  DebugTree({this.printTimeType = TIME_CLOCK, this.logLevels = DEFAULT}) {
    if (printTimeType == TIME_ELAPSED) {
      _elapsedTimeStopwatch = Stopwatch();
      _elapsedTimeStopwatch.start();
    }
  }

  factory DebugTree.elapsed({List<String> logLevels = DEFAULT}) {
    return DebugTree(logLevels: logLevels, printTimeType: TIME_ELAPSED);
  }

  @override
  log(String level, String msg, {String tag, dynamic ex}) {
    var logTag = tag ?? LogTree.getTag();
    if (ex != null) {
      var stackTrace =
      LogTree.getStacktrace().map((stackLine) => "\t$stackLine").join("\n");
      printLog("$level\t$logTag:\t $msg \n${ex.toString()}\n$stackTrace");
    } else {
      printLog("$level\t$logTag:\t $msg");
    }
  }

  /// Method to overload printing to output stream the formatted logline
  /// Adds handing of time
  printLog(String logLine) {
    if (printTimeType != null) {
      if (printTimeType == TIME_ELAPSED) {
        var timeElapsed = _elapsedTimeStopwatch.elapsed.toString();
        print("$timeElapsed\t$logLine");
      } else {
        var date = DateTime.now().toIso8601String();
        print("$date\t$logLine");
      }
    } else
      print(logLine);
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }
}

/// Interface for LogTree
abstract class LogTree {
  static const String _defaultTag = "Flutter";

  log(String level, String msg, {String tag, dynamic ex});

  List<String> getLevels();

  /// Gets tag with $stackIndex - how many steps in stacktrace should be taken to grab log call.
  static String getTag({int stackIndex = 6}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    if (stackTraceList.length > stackIndex) {
      var lineChunks = stackTraceList[stackIndex]
          .replaceFirst("<anonymous closure>", "<ac>");
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

  v(String msg, {dynamic ex}) {
    _log("V", tag, msg, ex: ex);
  }

  d(String msg, {dynamic ex}) {
    _log("D", tag, msg, ex: ex);
  }

  i(String msg, {dynamic ex}) {
    _log("I", tag, msg, ex: ex);
  }

  w(String msg, {dynamic ex}) {
    _log("W", tag, msg, ex: ex);
  }

  e(String msg, {dynamic ex}) {
    _log("E", tag, msg, ex: ex);
  }

  _log(String level, String tag, String msg, {dynamic ex}) {
    Fimber.log(level, msg, tag: tag, ex: ex);
  }
}
