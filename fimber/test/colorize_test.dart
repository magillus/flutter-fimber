import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() async {
  group('Colorize', () {
    setUp(() {
      print("setup test - Colorize");
      Fimber.clearAll();
    });
    tearDown(() {
      print("tear down test - Colorize");
      Fimber.clearAll();
    });

    test("Test colors", () async {
      var colorize = Colorize(foreground: AnsiColor.red);
      print("TEXT");
      print(colorize.wrap("TEXT"));
      colorize =
          Colorize(foreground: AnsiColor.blue, background: AnsiColor.black);
      print(colorize.wrap("TEXT STRING WITH BLUE"));
      colorize =
          Colorize(foreground: AnsiColor.cyan, background: AnsiColor.green);
      print("${colorize.wrap("TEXT more tests")}\n"
          "${colorize.wrap("TEST TEXT....", foreground: AnsiColor.white)}");

      print(Colorize.wrapWith("Magenta", foreground: AnsiColor.magenta));
      print(Colorize.wrapWith("Blue reversed",
          foreground: AnsiColor.blue, reverse: true));
      print(Colorize.wrapWith("Yellow and Green bright reversed",
          background: AnsiColor.green,
          foreground: AnsiColor.yellow,
          reverse: true));
      print(Colorize.wrapWith("Yellow bright", bright: AnsiColor.yellow));

      print(Colorize.wrapWith("Some text", foreground: AnsiColor.magenta));
      print("");
    });

    test("Test stylize", () {
      var style = ColorizeStyle([
        AnsiStyle(AnsiSelection.foreground, color: AnsiColor.green),
        AnsiStyle(AnsiSelection.background, color: AnsiColor.blue)
      ]);
      print(style.wrap("TEST GREEN ON blue"));

      var styleB = ColorizeStyle([
        AnsiStyle.background(AnsiColor.yellow),
        AnsiStyle.foreground(AnsiColor.black)
      ]);
      print(styleB.wrap("Test black on yellow background"));

      var styleGray30 = ColorizeStyle(
          [AnsiStyle.foreground(AnsiColor.bits)..bit9Pallete = 240]);
      print(styleGray30.wrap("Test with gray 30"));
      var styleGray60 = ColorizeStyle(
          [AnsiStyle.foreground(AnsiColor.bits)..bit9Pallete = 249]);
      print(styleGray60.wrap("Test with gray 60"));
    });
  });
}
