enum AnsiColor { BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE, NA }
enum AnsiSelection { FOREGROUND, BACKGROUND, REVERSED, BRIGHT }

class Colorize {
  static const _cmdCode = "\x1b[";

  static const _resetCode = "\x1b[0m";

//  static const Bright = "\x1b[1m";
//  static const Dim = "\x1b[2m";
//  static const Underscore = "\x1b[4m";
//  static const Blink = "\x1b[5m";
//  static const Reverse = "\x1b[7m";
//  static const Hidden = "\x1b[8m";

  static const _black = "0";
  static const _Red = "1";
  static const _green = "2";
  static const _yellow = "3";
  static const _blue = "4";
  static const _magenta = "5";
  static const _cyan = "6";
  static const _white = "7";

  static const _underlineType = "4";
  static const _reverseType = "7";
  static const _brightType = "9";
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
    switch (color) {
      case AnsiColor.BLACK:
        return _black;
      case AnsiColor.BLUE:
        return _blue;
      case AnsiColor.CYAN:
        return _cyan;
      case AnsiColor.GREEN:
        return _green;
      case AnsiColor.MAGENTA:
        return _magenta;
      case AnsiColor.RED:
        return _Red;
      case AnsiColor.WHITE:
        return _white;
      case AnsiColor.YELLOW:
        return _yellow;
      default:
        return "";
    }
  }

  static String wrapAnsi(String text, String ansiCode) {
    return "$_cmdCode${ansiCode}m$text$_resetCode";
  }
}
