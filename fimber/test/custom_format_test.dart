import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() {
  var dirSeparator = Platform.pathSeparator;
  group("Custom format", () {
    var testDirName = "test_logs-format";
    var logDir = Directory(testDirName);

    setUp(() {
      logDir.createSync(recursive: true);
    });
    tearDown(() {
      logDir.deleteSync(recursive: true);
    });

    test('Format based logger', () {
      print("");

      Fimber.clearAll();
      var defaultFormat = AssertFormattedTree();

      var elapsedMsg = AssertFormattedTree.elapsed(
          logFormat:
          "${CustomFormatTree.TIME_ELAPSED_TOKEN} ${CustomFormatTree
              .MESSAGE_TOKEN}");
      Fimber.plantTree(defaultFormat);
      Fimber.plantTree(elapsedMsg);

      Fimber.i("Test message A");
      Fimber.i("Test Message B", ex: Exception("Test exception"));

      assert(defaultFormat.logLineHistory[0]
          .contains("I main.<ac>.<ac>: Test message A"));
      assert(defaultFormat.logLineHistory[1]
          .contains("I main.<ac>.<ac>: Test Message B"));
      expect(
          defaultFormat.logLineHistory[0]
              .substring("2019-01-18T09:15:08.980493".length + 1),
          "I main.<ac>.<ac>: Test message A");

      assert(elapsedMsg.logLineHistory[0].contains("Test message A"));
      expect("Test message A",
          elapsedMsg.logLineHistory[0].substring("0:00:00.008303".length + 1));
    });

    test('File output logger', () async {
      var filePath = "${testDirName}${dirSeparator}test-output.logger.log.txt";
      var file = File(filePath);
      Fimber.clearAll();
      Fimber.plantTree(FimberFileTree(filePath));

      Fimber.i("Test log");

      await Future.delayed(Duration(seconds: 1));

      var lines = file.readAsLinesSync();
      print("File: ${file.absolute}");
      expect(lines.length, 1);
      expect("Test log",
          lines[0].substring("2019-02-03T07:19:59.417122".length + 1));
    });

    test('Time format detection', () async {
      var filePath = "${testDirName}${dirSeparator}test-format-detection.log.txt";
      Fimber.clearAll();
      Fimber.plantTree(FimberFileTree(filePath,
          logFormat:
          "${CustomFormatTree.TIME_ELAPSED_TOKEN} ${CustomFormatTree
              .MESSAGE_TOKEN} ${CustomFormatTree.TIME_STAMP_TOKEN}"));

      Fimber.i("Test log");

      await Future.delayed(Duration(seconds: 1));
      var file = File(filePath);
      var lines = file.readAsLinesSync();
      print("File: ${file.absolute}");
      assert(lines.length == 1);
      expect(
          lines[0].substring("0:00:00.008303".length + 1,
              lines[0].length - " 2019-01-22T06:51:58.062997".length),
          "Test log");
    });
  });
}

class AssertFormattedTree extends CustomFormatTree {
  AssertFormattedTree({String logFormat = CustomFormatTree.DEFAULT_FORMAT,
    int printTimeType = CustomFormatTree.TIME_CLOCK})
      : super(logFormat: logFormat);

  factory AssertFormattedTree.elapsed(
      {String logFormat = CustomFormatTree.DEFAULT_FORMAT}) {
    return AssertFormattedTree(logFormat: logFormat);
  }

  List<String> logLineHistory = [];

  @override
  void printLine(String line) {
    logLineHistory.add(line);
    super.printLine(line);
  }
}
