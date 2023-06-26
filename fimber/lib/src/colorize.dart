/// Color types for ANSI console standard
enum AnsiColor {
  /// Black color type
  black,

  /// Red color type
  red,

  /// Green color type
  green,

  /// Yellow color type
  yellow,

  /// Blue color type
  blue,

  /// Magenta color type
  magenta,

  /// Cyan color type
  cyan,

  /// White color type
  white,

  /// Custom color type with Bit 8 (not supported)
  bits
}

/// Type of Selection for the Ansi style/color
enum AnsiSelection {
  /// Foreground color style selection
  foreground,

  /// Background color style selection
  background,

  /// Reversed style selection - toggle
  reversed,

  /// Bright style selection - enables bright
  bright,

  /// Underline style selection - enables
  underline
}

/// Console style definition with color and type of "selection"
///
class AnsiStyle {
  /// Color part of the style
  AnsiColor? color;

  /// Style's selection
  AnsiSelection selection;

  /// If supported bit9 palette
  int?
      bit9Pallete; // todo add support for 8bit https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit

  /// Creates style by its selection and optional color details
  AnsiStyle(this.selection, {this.color, this.bit9Pallete});

  /// Returns section code for ANSI style entry.
  String _selectionCode() {
    switch (selection) {
      case AnsiSelection.background:
        return "4";
      case AnsiSelection.foreground:
        return "3";
      case AnsiSelection.reversed:
        return "7";
      case AnsiSelection.bright:
        return "9";
      case AnsiSelection.underline:
        return "4";
    }
  }

  /// returns color code for ANSI style entry.
  String _colorCode() {
    if (bit9Pallete != null && color == AnsiColor.bits) {
      return "8;5;$bit9Pallete";
    } else {
      return color?.index.toString() ?? "";
    }
  }

  /// Applies defined style into the text.
  String apply(String text) {
    return Colorize._wrapAnsi(text, _selectionCode() + _colorCode());
  }

  /// Creates Bright style with color
  factory AnsiStyle.bright(AnsiColor color) {
    return AnsiStyle(AnsiSelection.bright, color: color);
  }

  /// Creates Reversed style.
  factory AnsiStyle.reversed() {
    return AnsiStyle(AnsiSelection.reversed);
  }

  /// Creates underline style.
  factory AnsiStyle.underline() {
    return AnsiStyle(AnsiSelection.underline);
  }

  /// Creates foreground style with color
  factory AnsiStyle.foreground(AnsiColor color) {
    return AnsiStyle(AnsiSelection.foreground, color: color);
  }

  /// Creates background style with color.
  factory AnsiStyle.background(AnsiColor color) {
    return AnsiStyle(AnsiSelection.background, color: color);
  }
}

/// Usage by style pickers from enums and list of style applied in order.
class ColorizeStyle {
  final List<AnsiStyle> _styles = [];

  /// Creates colorize Style from list of AnsiStyles.
  ColorizeStyle(List<AnsiStyle> styles) {
    _styles.addAll(styles);
  }

  /// Wraps a text with list of AnsiStyles.
  String wrap(String text, {List<AnsiStyle> additionalStyles = const []}) {
    final List<AnsiStyle> styles = List.from(_styles)..addAll(additionalStyles);
    String retString = text;
    for (final AnsiStyle style in styles) {
      retString = style.apply(retString);
    }
    return retString;
  }
}

/// Colorize class that wraps text with defined values.
class Colorize {
  static const _cmdCode = "\x1b[";

  static const _resetCode = "\x1b[0m";

  static const _underlineType = "4";
  static const _reverseType = "7";
  static const _brightType = "9";
  static const _blinkType = "5";
  static const _foregroundType = "3";
  static const _backgroundType = "4";

  /// Colorize will apply foreground color of style if provided
  AnsiColor? foreground;

  /// Colorize will apply background color of style if provided
  AnsiColor? background;

  /// Colorize will apply bright style if provided
  AnsiColor? bright;

  /// Colorize will apply reverse style if provided
  bool reverse = false;

  /// Colorize will apply underline style if provided
  bool underline = false;

  /// Creates Colorize class with defined styles.
  Colorize({
    this.foreground,
    this.background,
    this.bright,
    this.reverse = false,
    this.underline = false,
  });

  /// Wraps text into the defined styles with option to override a style.
  String wrap(
    String text, {
    AnsiColor? foreground,
    AnsiColor? background,
    AnsiColor? bright,
    bool? reverse,
    bool? underline,
  }) {
    final underlineStyle = (underline ?? false) ? underline : this.underline;

    final rvStyle = (reverse ?? false) ? reverse : this.reverse;

    final fgColor = (foreground != null)
        ? foreground
        : (this.foreground != null)
            ? this.foreground
            : null;

    final bgColor = (background != null)
        ? background
        : (this.background != null)
            ? this.background
            : null;
    final brColor = (bright != null)
        ? bright
        : (this.bright != null)
            ? this.bright
            : null;
    return wrapWith(
      text,
      background: bgColor,
      foreground: fgColor,
      bright: brColor,
      reverse: rvStyle,
      underline: underlineStyle,
    );
  }

  /// Wraps text with provided styles.
  static String wrapWith(
    String text, {
    AnsiColor? background,
    AnsiColor? foreground,
    AnsiColor? bright,
    bool? reverse,
    bool? underline,
  }) {
    var retString = text;
    if (reverse ?? false) {
      // if reverse and background/foreground are specified we should reverse their colors
      if (background != null || foreground != null || bright != null) {
        final tmp = background;
        background = foreground ?? bright;
        foreground = tmp;
      } else {
        retString = _wrapAnsi(retString, _reverseType);
      }
    }
    if (underline ?? false) {
      retString = _wrapAnsi(retString, _underlineType);
    }
    if (foreground != null) {
      retString = _wrapSingle(retString, foreground: foreground);
    }
    if (background != null) {
      retString = _wrapSingle(retString, background: background);
    }
    if (bright != null) {
      retString = _wrapSingle(retString, bright: bright);
    }
    return retString;
  }

  static String _wrapSingle(
    String text, {
    AnsiColor? foreground,
    AnsiColor? background,
    AnsiColor? bright,
    bool? blink,
  }) {
    var style = _foregroundType;
    var color = foreground;
    if (blink ?? false) {
      style = _blinkType;
      color = background;
    } else if (bright != null) {
      style = _brightType;
      color = bright;
    } else if (background != null) {
      style = _backgroundType;
      color = background;
    }
    if (color != null) {
      return _wrapAnsi(text, style + _colorCode(color));
    } else {
      return text;
    }
  }

  static String _colorCode(AnsiColor color) {
    return color.index.toString();
  }

  static String _wrapAnsi(String text, String ansiCode) {
    return "$_cmdCode${ansiCode}m$text$_resetCode";
  }
}
