import 'package:fimber/fimber.dart';

class ColorizeDebugTree extends LogTree {
  ColorizeDebugTree({this.printTimeType = TIME_CLOCK, this.logLevels = DEFAULT}) {
    if (printTimeType == TIME_ELAPSED) {
      _elapsedTimeStopwatch = Stopwatch();
      _elapsedTimeStopwatch.start();
    }
  }

  factory ColorizeDebugTree.elapsed({List<String> logLevels = DEFAULT}) {
    return ColorizeDebugTree(logLevels: logLevels, printTimeType: TIME_ELAPSED);
  }

  static const List<String> DEFAULT = ['D', 'I', 'W', 'V', 'E'];
  static const int TIME_ELAPSED = 0;
  static const int TIME_CLOCK = 1;
  List<String> logLevels;
  final int printTimeType;
  Stopwatch _elapsedTimeStopwatch;

  @override
  void log(String level, String msg, {String tag, dynamic ex, StackTrace stacktrace}) {
    final logTag = tag ?? LogTree.getTag();
    if (ex != null) {
      final tmpStacktrace = stacktrace?.toString()?.split('\n') ?? LogTree.getStacktrace();
      final stackTraceMessage = tmpStacktrace.map((stackLine) => '\t$stackLine').join('\n');
      _formatWithTime(level, '$level\t$logTag:\t $msg \n${ex.toString()}\n$stackTraceMessage');
    } else {
      _formatWithTime(level, '$level\t$logTag:\t $msg');
    }
  }

  /// Method to overload printing to output stream the formatted logline
  /// Adds handing of time
  void _formatWithTime(String level, String logLine) {
    if (printTimeType != null) {
      if (printTimeType == TIME_ELAPSED) {
        final timeElapsed = _elapsedTimeStopwatch.elapsed.toString();
        _formatLevelStyle(level, '$timeElapsed\t$logLine');
      } else {
        final date = DateTime.now().toIso8601String();
        _formatLevelStyle(level, '$date\t$logLine');
      }
    } else {
      _formatLevelStyle(level, logLine);
    }
  }

  void _formatLevelStyle(String level, String logLine) {
    switch (level) {
      case 'D':
        print(logLine);
        /* _print(
          logLine,
          foreground: Styles.WhiteForeground,
        ); */
        break;
      case 'I':
        _print(
          logLine,
          foreground: Styles.CyanForeground,
        );
        break;
      case 'V':
        _print(
          logLine,
          foreground: Styles.YellowBright,
        );
        break;
      case 'W':
        _print(
          logLine,
          foreground: Styles.MagentaBright,
        );
        break;
      case 'F': // FATAL - not implemented in Fimber core
        _print(
          logLine,
          foreground: Styles.WhiteForeground,
          background: Styles.MagentaBackground,
        );
        break;
      case 'E':
        _print(
          logLine,
          foreground: Styles.WhiteBright,
          background: Styles.RedBackground,
        );
        break;
      default:
        print(logLine);
    }
  }

  void _print(String logLine, {Styles foreground, Styles background}) {
    final error = Colorize(logLine);
    if (foreground != null) {
      error.apply(foreground);
    }
    if (background != null) {
      error.apply(background);
    }
    print(error);
  }

  @override
  List<String> getLevels() {
    return logLevels;
  }
}

class Colorize {
  Colorize([this.initial = '']);
  static const String _kEsc = '\x1B';//'\u{1B}';
  String initial = '';

  @override
  String toString() => initial;

  Colorize apply(Styles style, [String text]) {
    text ??= initial;
    initial = _applyStyle(style, text);
    return this;
  }

  String buildEscSeq(Styles style) {
    return _kEsc + '[${getStyle(style)}m';
  }

  String _applyStyle(Styles style, String text) {
    return buildEscSeq(style) + text + buildEscSeq(Styles.Reset);
  }

  /// [ANSI_escape_code#Colors](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors)
  /// [Print in terminal with colors](https://stackoverflow.com/questions/287871/print-in-terminal-with-colors#)
  static String getStyle(Styles style) {
    switch (style) {
      case Styles.Reset:
        return '0';
      case Styles.Bright:
        return '1';
      case Styles.Dim:
        return '2';
      case Styles.Underscore:
        return '4';
      case Styles.Blink:
        return '5';
      case Styles.Reverse:
        return '7';
      case Styles.Hidden:
        return '8';

      case Styles.BlackForeground:
        return '30';
      case Styles.RedForeground:
        return '31';
      case Styles.GreenForeground:
        return '32';
      case Styles.YellowForeground:
        return '33';
      case Styles.BlueForeground:
        return '34';
      case Styles.MagentaForeground:
        return '35';
      case Styles.CyanForeground:
        return '36';
      case Styles.WhiteForeground:
        return '37';

      case Styles.BlackBackground:
        return '40';
      case Styles.RedBackground:
        return '41';
      case Styles.GreenBackground:
        return '42';
      case Styles.YellowBackground:
        return '43';
      case Styles.BlueBackground:
        return '44';
      case Styles.MagentaBackground:
        return '45';
      case Styles.CyanBackground:
        return '46';
      case Styles.WhiteBackground:
        return '47';

      case Styles.BlackBright:
        return '90';
      case Styles.RedBright:
        return '91';
      case Styles.GreenBright:
        return '92';
      case Styles.YellowBright:
        return '93';
      case Styles.BlueBright:
        return '94';
      case Styles.MagentaBright:
        return '95';
      case Styles.CyanBright:
        return '96';
      case Styles.WhiteBright:
        return '97';

      default:
        return '';
    }
  }
}

enum Styles {
  Reset,
  Bright,
  Dim,
  Underscore,
  Blink,
  Reverse,
  Hidden,
  BlackForeground,
  RedForeground,
  GreenForeground,
  YellowForeground,
  BlueForeground,
  MagentaForeground,
  CyanForeground,
  WhiteForeground,
  BlackBackground,
  RedBackground,
  GreenBackground,
  YellowBackground,
  BlueBackground,
  MagentaBackground,
  CyanBackground,
  WhiteBackground,
  BlackBright,
  RedBright,
  GreenBright,
  YellowBright,
  BlueBright,
  MagentaBright,
  CyanBright,
  WhiteBright,
}
