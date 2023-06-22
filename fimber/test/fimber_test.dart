import 'package:fimber/fimber.dart';
import 'package:fimber/src/fimber_base.dart';
import 'package:test/test.dart';

void main() {
  group("STATIC", () {
    test('log DEBUG when filtered out', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W"]);
      Fimber.plantTree(assertTree);
      Fimber.d("Test message", ex: Exception("test error"));
      expect('', assertTree.lastLogLine);
    });

    test('log DEBUG when expected', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D"]);
      Fimber.plantTree(DebugTree());
      Fimber.plantTree(assertTree);
      Fimber.d("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine != '');
    });

    test('log DEBUG with exception', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D"]);
      Fimber.plantTree(assertTree);
      Fimber.d("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
    });

    test('log INFO message tag', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W"]);
      Fimber.plantTree(assertTree);
      Fimber.i("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("I:main"));
    });

    test('log DEBUG message tag', () {
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.d("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("D:main"));
    });

    test('log VERBOSE message tag', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.v("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("V:main"));
    });

    test('log ERROR message tag', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.e("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("E:main"));
    });

    test('log WARNING message tag', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      Fimber.w("Test message");
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("W:main"));
    });
  });

  group("TAGGED", () {
    test('log VERBOSE message with exception', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      final logger = FimberLog("MYTAG");
      logger.v("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("V:MYTAG"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
    });

    test('log DEBUG message with exception', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      final logger = FimberLog("MYTAG");
      logger.d("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("D:MYTAG"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
    });

    test('log INFO message with exception', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      final logger = FimberLog("MYTAG");
      logger.i("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
      assert(assertTree.lastLogLine.contains("I:MYTAG"));
    });

    test('log WARNING message with exception', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      final logger = FimberLog("MYTAG");
      logger.w("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
      assert(assertTree.lastLogLine.contains("W:MYTAG"));
    });

    test('log ERROR message with exception', () {
      Fimber.clearAll();
      final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
      Fimber.plantTree(assertTree);
      final logger = FimberLog("MYTAG");
      logger.e("Test message", ex: Exception("test error"));
      assert(assertTree.lastLogLine.contains("Test message"));
      assert(assertTree.lastLogLine.contains("test error"));
      assert(assertTree.lastLogLine.contains("E:MYTAG"));
    });
  });

  test('Test with block tag', () {
    Fimber.clearAll();
    final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree());
    const someMessage = "Test message from outside of block";
    final output = Fimber.withTag("TEST BLOCK", (log) {
      log.d("Started block");
      var i = 0;
      for (i = 0; i < 10; i++) {
        log.d("$someMessage, value: $i");
      }
      log.i("End of block");
      return i;
    });
    expect(10, output);
    expect(12, assertTree.allLines.length);
    for (final line in assertTree.allLines) {
      // test tag
      assert(line.contains("TEST BLOCK"));
    }
    //inside lines contain external value
    for (final line in assertTree.allLines.sublist(1, 11)) {
      assert(line.contains(someMessage));
      assert(line.contains("D:TEST BLOCK"));
    }
  });

  test('Test with block autotag', () {
    Fimber.clearAll();
    final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree());
    const someMessage = "Test message from outside of block";
    final output = Fimber.block((log) {
      log.d("Started block");
      var i = 0;
      for (i = 0; i < 10; i++) {
        log.d("$someMessage, value: $i");
      }
      log.i("End of block");
      return i;
    });
    expect(10, output);
    expect(12, assertTree.allLines.length); // 10 + start and end line
    for (final line in assertTree.allLines) {
      // test tag
      assert(line.contains("main"));
    }
    //inside lines contain external value
    for (final line in assertTree.allLines.sublist(1, 11)) {
      assert(line.contains(someMessage));
      assert(line.contains("D:main"));
    }
  });

  test('Unplant trees test', () {
    Fimber.clearAll();
    final assertTreeA = AssertTree(["I", "W", "D", "E", "V"]);
    final assertTreeB = AssertTree(["I", "W", "E"]);
    Fimber.plantTree(assertTreeA);
    Fimber.plantTree(assertTreeB);
    Fimber.plantTree(DebugTree(printTimeType: DebugTree.timeElapsedType));

    Fimber.e("Test Error");
    Fimber.w("Test Warning");
    Fimber.i("Test Info");
    Fimber.d("Test Debug");

    expect(4, assertTreeA.allLines.length);
    expect(3, assertTreeB.allLines.length);

    Fimber.unplantTree(assertTreeA);
    Fimber.i("Test Info");
    Fimber.d("Test Debug");
    Fimber.w("Test Warning");
    Fimber.e("Test Error");

    expect(4, assertTreeA.allLines.length);
    expect(6, assertTreeB.allLines.length);
  });

  test('Constructor Log Tag generation', () {
    Fimber.clearAll();

    final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree());

    Fimber.i("Start log test");
    TestClass();
    Fimber.i("End log test");
    expect(3, assertTree.allLines.length);
    assert(assertTree.allLines[1].contains("new TestClass"));
  });

  test('Factory method Log Tag generation', () {
    Fimber.clearAll();

    final assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree.elapsed());

    Fimber.i("Start log test");
    TestClass.factory1();
    Fimber.i("End log test");
    expect(4, assertTree.allLines.length);
    assert(assertTree.allLines[1].contains("new TestClass.factory1"));
    assert(assertTree.allLines[2].contains("new TestClass"));
  });

  test('Throw Error and other any class', () {
    Fimber.clearAll();
    final assertTree = AssertTree(["I", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree.elapsed());
    Fimber.i("Test log statement");
    Fimber.i("Test throw ERROR", ex: ArgumentError.notNull("testValue"));
    Fimber.i("Test throw DATA", ex: TestClass());
    Fimber.w("End log statment");
    assert(
      assertTree.allLines[1]
          .contains("Invalid argument(s) (testValue): Must not be null"),
    );
    assert(assertTree.allLines[3].contains("TestClass.instance"));
  });

  test('Test Stacktrace', () {
    Fimber.clearAll();
    final assertTree = AssertTree(["I", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.plantTree(DebugTree.elapsed());
    Fimber.i("Test log statement");
    final testClass = TestClass();
    try {
      testClass.throwSomeError();
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      Fimber.w("Error caught 1", ex: e, stacktrace: s);
    }
    try {
      testClass.throwSomeError();
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      Fimber.w("Error caught 2", ex: e);
    }
    try {
      testClass.throwSomeError();
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      Fimber.w("Error caught 3", stacktrace: s);
    }
    // with stacktrace provided
    assert(assertTree.allLines[2].contains("Error caught"));
    assert(assertTree.allLines[2].contains("Test exception from TestClass"));
    assert(assertTree.allLines[2].contains("TestClass.throwSomeError"));
    // without stacktrace provided
    assert(assertTree.allLines[3].contains("Test exception from TestClass"));
    assert(!assertTree.allLines[3].contains("TestClass.throwSomeError"));
    // without exception

    assert(assertTree.allLines[4].contains("Error caught"));

    assert(!assertTree.allLines[4].contains("Test exception from TestClass"));
    assert(assertTree.allLines[4].contains("TestClass.throwSomeError"));
  });

  test('Test mute/unmute', () {
    Fimber.clearAll();
    final assertTree = AssertTree(["V", "I", "D", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.i("Test INFO log.");
    Fimber.mute("I");
    Fimber.i("Test INFO mute log.");
    Fimber.unmute("I");
    Fimber.i("Test INFO unmute log.");

    expect(2, assertTree.allLines.length);
    assert(assertTree.allLines[0].contains("Test INFO log."));
    assert(assertTree.allLines[1].contains("Test INFO unmute log."));
  });

  test('Test Multiple mute and unmute', () {
    Fimber.clearAll();
    final assertTree = AssertTree(["V", "I", "D", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.i("Test INFO log.");
    Fimber.mute("I");
    Fimber.i("Test INFO mute log.");
    Fimber.mute("I");
    Fimber.i("Test INFO mute log.");
    Fimber.unmute("I");
    Fimber.i("Test INFO unmute log.");

    expect(2, assertTree.allLines.length);
    assert(assertTree.allLines[0].contains("Test INFO log."));
    assert(assertTree.allLines[1].contains("Test INFO unmute log."));
  });

  group("Custom format tree", () {
    test("Test custom format with linenumber", () {
      final formatTree = AssertFormatTree(
        "${CustomFormatTree.tagToken}\t${CustomFormatTree.fileNameToken}\t- ${CustomFormatTree.filePathToken} : ${CustomFormatTree.lineNumberToken}",
      );
      Fimber.plantTree(formatTree);
      Fimber.i("Test message");
      assert(
        formatTree.allLines.first
            .startsWith('main.<ac>.<ac>\tfimber_test.dart\t'),
      );
      assert(
        formatTree.allLines.first
            .endsWith('flutter-fimber/fimber/test/fimber_test.dart : 340'),
      );

      Fimber.unplantTree(formatTree);
    });
  });

  group("COLORIZE", () {
    test("Debug colors - visual test only", () {
      Fimber.clearAll();
      Fimber.plantTree(
        DebugTree(logLevels: ["V", "D", "I", "W", "E"], useColors: true),
      );
      Fimber.v("verbose logging");
      Fimber.d("debug logging");
      Fimber.i("info logging");
      Fimber.w("warning logging");
      Fimber.e("error logging");
    });
  });
}

class TestClass {
  TestClass() {
    Fimber.i("Logging from test class constructor.");
  }

  factory TestClass.factory1() {
    Fimber.i("Logging from factory method");
    return TestClass();
  }

  /// Throws some error
  void throwSomeError() {
    throw Exception("Test exception from TestClass");
  }

  @override
  String toString() {
    return "TestClass.instance";
  }
}

class AssertFormatTree extends CustomFormatTree {
  AssertFormatTree(String testLogFormat) : super(logFormat: testLogFormat);
  List<String> allLines = [];
  @override
  void printLine(String line, {String? level}) {
    super.printLine(line, level: level);
    allLines.add(line);
  }
}

class AssertTree extends LogTree {
  List<String> logLevels = [];
  String lastLogLine = "";
  List<String> allLines = [];

  AssertTree(this.logLevels);

  @override
  List<String> getLevels() {
    return logLevels;
  }

  @override
  void log(
    String level,
    String msg, {
    String? tag,
    dynamic? ex,
    StackTrace? stacktrace,
  }) {
    tag = (tag ?? LogTree.getTag());
    final newLogLine =
        "$level:$tag\t$msg\t$ex\n${stacktrace?.toString().split('\n') ?? ""}";
    lastLogLine = newLogLine;
    allLines.add(newLogLine);
  }
}
