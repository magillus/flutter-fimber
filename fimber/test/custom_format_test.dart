import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() {
  group("Custom format", () {
    test('Format based logger', () {
      print("");

      Fimber.clearAll();
      var defaultFormat = AssertFormattedTree();

      var elapsedMsg = AssertFormattedTree.elapsed(
          logFormat: '''${CustomFormatTree.timeElapsedToken}
${CustomFormatTree.messageToken}''');
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
  });
}

class AssertFormattedTree extends CustomFormatTree {
  AssertFormattedTree(
      {String logFormat = CustomFormatTree.defaultFormat,
      int printTimeType = CustomFormatTree.timeClockFlag})
      : super(logFormat: logFormat);

  factory AssertFormattedTree.elapsed(
      {String logFormat = CustomFormatTree.defaultFormat}) {
    return AssertFormattedTree(logFormat: logFormat);
  }

  List<String> logLineHistory = [];

  @override
  void printLine(String line, {String? level}) {
    logLineHistory.add(line);
    super.printLine(line, level: level);
  }
}
