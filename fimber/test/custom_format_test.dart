import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() {
  test('Format based logger', () {
    print("");

    Fimber.clearAll();
    var defaultFormat = AssertFormattedTree();

    var elapsedMsg = AssertFormattedTree.elapsed(
        logFormat:
            "${CustomFormatTree.TIME_ELAPSED_TOKEN} ${CustomFormatTree.MESSAGE_TOKEN}");
    Fimber.plantTree(defaultFormat);
    Fimber.plantTree(elapsedMsg);

    Fimber.i("Test message A");
    Fimber.i("Test Message B", ex: Exception("Test exception"));

    assert(defaultFormat.logLineHistory[0]
        .contains("I	main.<ac>:	 Test message A"));
    assert(defaultFormat.logLineHistory[1]
        .contains("I	main.<ac>:	 Test Message B"));
    expect(
        defaultFormat.logLineHistory[0]
            .substring("2019-01-18T09:15:08.980493".length + 1),
        "I	main.<ac>:	 Test message A");

    assert(elapsedMsg.logLineHistory[0].contains("Test message A"));
    expect("Test message A",
        elapsedMsg.logLineHistory[0].substring("0:00:00.008303".length + 1));
  });

  test('File output logger', () async {
    var filePath = "test.log.txt";
    Fimber.clearAll();
    Fimber.plantTree(FimberFileTree(filePath));

    Fimber.i("Test log");

    await Future.delayed(Duration(seconds: 1));
    var file = File(filePath);
    var lines = file.readAsLinesSync();
    print("File: ${file.absolute}");
    assert(lines.length == 1);
    expect("Test log", lines[0].substring("0:00:00.008303".length + 1));

    file.delete();
  });
}

class AssertFormattedTree extends CustomFormatTree {
  AssertFormattedTree(
      {String logFormat, int printTimeType = CustomFormatTree.TIME_CLOCK})
      : super(logFormat: logFormat, printTimeType: printTimeType);

  factory AssertFormattedTree.elapsed({String logFormat}) {
    return AssertFormattedTree(
        logFormat: logFormat, printTimeType: CustomFormatTree.TIME_ELAPSED);
  }

  List<String> logLineHistory = [];

  @override
  void printLine(String line) {
    logLineHistory.add(line);
    super.printLine(line);
  }
}
