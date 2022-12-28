import 'dart:async';
import 'dart:core';
import 'dart:io';

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
  StreamSubscription<List<String>>? _bufferWriteInterval;
  int _maxBufferSize = bufferSizeLimit;

  /// Creates Instance of FimberFileTree
  /// with optional [logFormat] from [CustomFormatTree] predicates.
  /// Takes optional [maxBufferSize] (default 1kB) and
  /// optional [bufferWriteInterval] in milliseconds.
  FimberFileTree(this.outputFileName,
      {logLevels = CustomFormatTree.defaultLevels,
      logFormat = '${CustomFormatTree.timeStampToken}'
          '\t${CustomFormatTree.messageToken}',
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
      await _flushBuffer(newLines);
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

  Future _flushBuffer(List<String> buffer) async {
    if (buffer.isNotEmpty) {
      IOSink? logSink;
      try {
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
      } finally {
        await logSink?.close();
      }
    }
  }

  /// Creates Fimber File tree with time tracking as elapsed
  /// from start of the process.
  factory FimberFileTree.elapsed(String fileName,
      {List<String> logLevels = CustomFormatTree.defaultLevels}) {
    return FimberFileTree(fileName,
        logFormat: '${CustomFormatTree.timeElapsedToken}'
            '\t${CustomFormatTree.messageToken}');
  }

  @override
  void printLine(String line, {String? level}) {
    var colorizeWrapper = (level != null) ? colorizeMap[level] : null;
    if (colorizeWrapper != null) {
      _logBuffer.add(colorizeWrapper.wrap(line));
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
      this.filenamePrefix = 'log_',
      this.filenamePostfix = '.txt',
      logLevels = CustomFormatTree.defaultLevels})
      : super(logFormat: logFormat, logLevels: logLevels) {
    detectFileIndex();
  }

  /// Detects file index based on same [filenamePrefix] and [filenamePostfix]
  /// and based on current files in the log directory.
  void detectFileIndex() {
    var rootDir;

    if (filenamePrefix.contains(Platform.pathSeparator)) {
      /// Create if separator has directories
      Directory(filenamePrefix).parent.createSync(recursive: true);
    } else {
      rootDir = Directory(filenamePrefix);
      if (!rootDir.existsSync()) {
        /// no files created yet.
        _fileIndex = 0;
        rollToNextFile();
        return;
      }
    }

    rootDir = Directory(filenamePrefix).parent;

    var logListIndexes = rootDir
        .listSync()
        .map((fe) => getLogIndex(fe.path))
        .where((i) => (i >= 0) as bool)
        .toList();
    logListIndexes.sort();
    print('log list indexes: $logListIndexes');
    if (logListIndexes.isNotEmpty) {
      var max = logListIndexes.last;
      _fileIndex = max;
      if (_isFileOverSize(_logFile(max))) {
        rollToNextFile();
      } else {
        outputFileName = _currentFile();
        print('Logfile is $outputFileName');
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
      '${filenamePrefix.replaceAll("\\", "\\\\")}([0-9]+)?$filenamePostfix');

  /// Gets log index from a file path.
  int getLogIndex(String filePath) {
    if (isLogFile(filePath)) {
      return _fileRegExp.allMatches(filePath).map((match) {
        if (match.groupCount > 0) {
          var parseGroup = match.group(1);
          if (parseGroup != null) {
            return int.parse(parseGroup);
          }
        }
        return -1;
      }).firstWhere((i) => i != -1, orElse: () => -1);
    } else {
      return -1;
    }
  }

  /// Checks if this is matching log file.
  bool isLogFile(String filePath) {
    return _fileRegExp.allMatches(filePath).map((match) {
      if (match.groupCount > 0) {
        return true;
      } else {
        return false;
      }
    }).lastWhere((_) => true, orElse: () => false);
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
  int maxHistoryFiles = 10;
  DateTime _currentFileDate = DateTime.now();

  /// Generated filename prefix, supports path to the file.
  String filenamePrefix;

  /// Generated filename postfix
  String filenamePostfix;

  /// Log filename formatter see: [LogFileNameFormatter]
  late LogFileNameFormatter fileNameFormatter;

  /// Creates Time based rolling file tree.
  /// It allows to define time span when this
  TimedRollingFileTree(
      {this.timeSpan = TimedRollingFileTree.dailyTime,
      logFormat = CustomFormatTree.defaultFormat,
      this.filenamePrefix = 'log_',
      this.filenamePostfix = '.txt',
      logLevels = CustomFormatTree.defaultLevels})
      : super(logLevels: logLevels, logFormat: logFormat) {
    fileNameFormatter = LogFileNameFormatter.full(
        prefix: filenamePrefix, postfix: filenamePostfix);
    rollToNextFile();
  }

  @override
  void rollToNextFile() {
    outputFileName = fileNameFormatter.format(_currentFileDate);
    _cleanupHistoryFiles();
  }

  Future<void> _cleanupHistoryFiles() async {
    final basePath = filenamePrefix.split('/').first;
    printLine('Base file path: $basePath');
    final files = await Directory(basePath).list().toList();
    files
        .sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
    // list all files in directory
    if (files.length > maxHistoryFiles) {
      var filesToKeep = maxHistoryFiles;
      for (var i = 0; i < files.length; i++) {
        // if file matches the filename formatter?
        if (fileNameFormatter
            .doesFileNameMatch(files[i].uri.pathSegments.last)) {
          // count down max history files
          filesToKeep--;
        }
        // if history is maxed out - delete file.
        if (filesToKeep <= 0) {
          files[i].deleteSync();
        }
      }
    }

    files.forEach((element) {
      fileNameFormatter.doesFileNameMatch(element.uri.pathSegments.last);
    });
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
  void printLine(String line, {String? level}) async {
    if (await shouldRollNextFile()) {
      rollToNextFile();
    }
    super.printLine(line, level: level);
  }
}
