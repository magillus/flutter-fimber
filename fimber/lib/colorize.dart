enum AnsiColor { BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, BIT8 }
enum AnsiSelection { FOREGROUND, BACKGROUND, REVERSED, BRIGHT, UNDERLINE }

/// Console style definition with color and type of "selection"
///
class AnsiStyle {
  AnsiColor color;
  AnsiSelection selection;
  int bit9Pallete = null; // todo add support for 8bit https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit

  AnsiStyle(this.selection, {this.color, this.bit9Pallete});

  String _selectionCode() {
    if (selection != null) {
      switch (selection) {
        case AnsiSelection.BACKGROUND:
          return "4";
        case AnsiSelection.FOREGROUND:
          return "3";
        case AnsiSelection.REVERSED:
          return "7";
        case AnsiSelection.BRIGHT:
          return "9";
        case AnsiSelection.UNDERLINE:
          return "4";
      }
    }
    return "";
  }

  String _colorCode() {
    if (bit9Pallete != null && color == AnsiColor.BIT8) {
      return "8;5;$bit9Pallete";
    } else
      return color?.index?.toString() ?? "";
  }

  String apply(String retString) {
    return Colorize.wrapAnsi(retString, _selectionCode() + _colorCode());
  }

  factory AnsiStyle.bright(AnsiColor color) {
    return AnsiStyle(AnsiSelection.BRIGHT, color: color);
  }

  factory AnsiStyle.reversed() {
    return AnsiStyle(AnsiSelection.REVERSED);
  }

  factory AnsiStyle.underline() {
    return AnsiStyle(AnsiSelection.UNDERLINE);
  }

  factory AnsiStyle.foreground(AnsiColor color) {
    return AnsiStyle(AnsiSelection.FOREGROUND, color: color);
  }

  factory AnsiStyle.background(AnsiColor color) {
    return AnsiStyle(AnsiSelection.BACKGROUND, color: color);
  }
}

/// Usage by style pickers from enums and list of style applied in order.
class ColorizeStyle {
  final List<AnsiStyle> _styles = [];

  ColorizeStyle(List<AnsiStyle> styles) {
    this._styles.addAll(styles);
  }

  String wrap(String text, {List<AnsiStyle> additionalStyles}) {
    List<AnsiStyle> styles = List.from(_styles)
      ..addAll(additionalStyles ?? []);
    var retString = text;
    styles.forEach((style) {
      retString = style.apply(retString);
    });
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

  AnsiColor foreground = null;
  AnsiColor background = null;
  AnsiColor bright = null;
  bool reverse = false;
  bool underline = false;

  Colorize(
      {this.foreground,
      this.background,
      this.bright,
      this.reverse,
      this.underline});

  String wrap(String text,
      {AnsiColor foreground = null,
      AnsiColor background = null,
      AnsiColor bright = null,
      bool reverse = false,
      bool underline = false}) {
    var underlineStyle = (underline ?? false)
        ? underline
        : (this.underline ?? false) ? this.underline : false;

    var rvStyle = (reverse ?? false)
        ? reverse
        : (this.reverse ?? false) ? this.reverse : false;

    var fgColor = (foreground != null)
        ? foreground
        : (this.foreground != null) ? this.foreground : null;

    var bgColor = (background != null)
        ? background
        : (this.background != null) ? this.background : null;
    var brColor =
        (bright != null) ? bright : (this.bright != null) ? this.bright : null;
    return wrapWith(text,
        background: bgColor,
        foreground: fgColor,
        bright: brColor,
        reverse: rvStyle,
        underline: underlineStyle);
  }

  static String wrapWith(String text,
      {AnsiColor background,
      AnsiColor foreground,
      AnsiColor bright,
      bool reverse = false,
      bool underline = false}) {
    String retString = text;
    if (reverse) {
      // if reverse and background/foreground are specified we should reverse their colors
      if (background != null || foreground != null || bright != null) {
        var tmp = background;
        background = foreground ?? bright;
        foreground = tmp;
      } else {
        retString = wrapAnsi(retString, _reverseType);
      }
    }
    if (underline) {
      retString = wrapAnsi(retString, _underlineType);
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

  static String _wrapSingle(String text,
      {AnsiColor foreground, AnsiColor background, AnsiColor bright}) {
    var style = _foregroundType;
    var color = foreground;
    if (bright != null) {
      style = _brightType;
      color = bright;
    }
    if (background != null) {
      style = _backgroundType;
      color = background;
    }
    if (style != null) {
      return wrapAnsi(text, style + _colorCode(color));
    } else {
      return text;
    }
  }

  static String _colorCode(AnsiColor color) {
    return color.index.toString();
  }

  static String wrapAnsi(String text, String ansiCode) {
    return "$_cmdCode${ansiCode}m$text$_resetCode";
  }
}
