import 'dart:io';

import 'package:fimber/colorize.dart';
import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() async {
  var dirSeparator = Platform.pathSeparator;

  group("Colorize", () {
    var testDirName = "test_logs";
    var logDir = Directory(testDirName);

    setUp(() {
      Fimber.clearAll();
      logDir.createSync(recursive: true);
    });
    tearDown(() {
      logDir.deleteSync(recursive: true);
    });

    test("Test colors", () async {
      var colorize = Colorize(foreground: AnsiColor.RED);
      print("TEXT");
      print(colorize.wrap("TEXT"));
      colorize =
          Colorize(foreground: AnsiColor.BLUE, background: AnsiColor.BLACK);
      print(colorize.wrap("TEXT STRING WITH BLUE"));
      colorize =
          Colorize(foreground: AnsiColor.CYAN, background: AnsiColor.GREEN);
      print(colorize.wrap("TEXT more tests") +
          "\n" +
          colorize.wrap("TESXT TEXT....", foreground: AnsiColor.WHITE));

      print(Colorize.wrapWith("Magenta", foreground: AnsiColor.MAGENTA));
      print(Colorize.wrapWith("Blue reversed",
          foreground: AnsiColor.BLUE, reverse: true));
      print(Colorize.wrapWith("Yellow and Green bright reversed",
          background: AnsiColor.GREEN,
          foreground: AnsiColor.YELLOW,
          reverse: true));
      print(Colorize.wrapWith("Yellow bright", bright: AnsiColor.YELLOW));

      print(Colorize.wrapWith("Some text", foreground: AnsiColor.MAGENTA));
      print("");

      print(Colorize.wrapAnsi("Some text 4", "4"));
      print(Colorize.wrapAnsi("Some text 7", "7"));
    });
  });
}
