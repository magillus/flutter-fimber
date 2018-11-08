library fimber;

/// Main static Fimber logging.
class Fimber {
  static v(String msg, {Exception ex}) {
    log("V", msg, ex: ex);
  }

  static d(String msg, {Exception ex}) {
    log("D", msg, ex: ex);
  }

  static i(String msg, {Exception ex}) {
    log("I", msg, ex: ex);
  }

  static w(String msg, {Exception ex}) {
    log("W", msg, ex: ex);
  }

  static e(String msg, {Exception ex}) {
    log("E", msg, ex: ex);
  }

  static log(String level, String msg, {String tag, Exception ex}) {
    _trees[level]
        ?.forEach((logger) => logger.log(level, msg, tag: tag, ex: ex));
  }

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

  static clearAll() {
    _trees.clear();
  }

  static Map<String, List<LogTree>> _trees = new Map<String, List<LogTree>>();

  static dynamic block(RunWithLog block) {
    return withTag(LogTree.getTag(stackIndex: 2), block);
  }

  static dynamic withTag(String tag, RunWithLog block) {
    var logger = FimberLog(tag);
    return block(logger);
  }
}

typedef RunWithLog = dynamic Function(FimberLog log);

/// Debug log tree. Tag generation included
class DebugTree extends LogTree {
  static const List<String> DEFAULT = ["D", "I", "W", "E"];
  List<String> logLevels;

  DebugTree({this.logLevels = DEFAULT});

  @override
  log(String level, String msg, {String tag, Exception ex}) {
    var logTag = tag ?? LogTree.getTag();
    if (logTag != null) {
      print("$level\t$logTag:\t $msg \n${ex?.toString() ?? ''}");
    } else {
      print("$level $msg \n${ex?.toString() ?? ''}");
    }
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }
}

/// Interface for LogTree
abstract class LogTree {
  log(String level, String msg, {String tag, Exception ex});

  List<String> getLevels();

  static String getTag({int stackIndex = 6}) {
    var stackTraceList = StackTrace.current.toString().split('\n');
    if (stackTraceList.length > stackIndex) {
      return stackTraceList[stackIndex]
          .replaceFirst("<anonymous closure>", "<ac>")
          .split(' ')[6]; // need better error handling
    } else {
      return "Flutter"; //default
    }
  }
}

/// Stand alone logger with custom tag defined.
class FimberLog {
  String tag;

  FimberLog(this.tag);

  v(String msg, {Exception ex}) {
    _log("V", tag, msg, ex: ex);
  }

  d(String msg, {Exception ex}) {
    _log("D", tag, msg, ex: ex);
  }

  i(String msg, {Exception ex}) {
    _log("I", tag, msg, ex: ex);
  }

  w(String msg, {Exception ex}) {
    _log("W", tag, msg, ex: ex);
  }

  e(String msg, {Exception ex}) {
    _log("E", tag, msg, ex: ex);
  }

  _log(String level, String tag, String msg, {Exception ex}) {
    Fimber.log(level, msg, tag: tag, ex: ex);
  }
}
