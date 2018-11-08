import 'package:flutter_test/flutter_test.dart';

import 'package:fimber/fimber.dart';

void main() {
  test('STATIC - log DEBUG when filtered out', () {
    var assertTree = AssertTree(["I", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.d("Test message", ex: Exception("test error"));
    expect(null, assertTree.lastLogLine);
  });

  test('STATIC - log DEBUG when expected', () {
    var assertTree = AssertTree(["I", "W", "D"]);
    Fimber.plantTree(assertTree);
    Fimber.d("Test message", ex: Exception("test error"));
    assert(assertTree.lastLogLine != null);
  });

  test('STATIC - log DEBUG with exception', () {
    var assertTree = AssertTree(["I", "W", "D"]);
    Fimber.plantTree(assertTree);
    Fimber.d("Test message", ex: Exception("test error"));
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("test error"));
  });

  test('STATIC - log INFO message tag', (){
    var assertTree = AssertTree(["I", "W"]);
    Fimber.plantTree(assertTree);
    Fimber.i("Test message");
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("I:main"));
  });

  test('STATIC - log DEBUG message tag', (){
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.d("Test message");
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("D:main"));
  });

  test('STATIC - log VERBOSE message tag', (){
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.v("Test message");
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("V:main"));
  });

  test('STATIC - log ERROR message tag', (){
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.e("Test message");
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("E:main"));
  });

  test('STATIC - log WARNING message tag', (){
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    Fimber.w("Test message");
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("W:main"));
  });

  test('TAGGED - log VERBOSE message with exception', () {
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    var logger = FimberLog("MYTAG");
    logger.v("Test message", ex: Exception("test error"));
    assert(assertTree.lastLogLine.contains("V:MYTAG"));
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("test error"));
  });

  test('TAGGED - log DEBUG message with exception', () {
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    var logger = FimberLog("MYTAG");
    logger.d("Test message", ex: Exception("test error"));
    assert(assertTree.lastLogLine.contains("D:MYTAG"));
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("test error"));
  });

  test('TAGGED - log INFO message with exception', () {
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    var logger = FimberLog("MYTAG");
    logger.i("Test message", ex: Exception("test error"));
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("test error"));
    assert(assertTree.lastLogLine.contains("I:MYTAG"));
  });

  test('TAGGED - log WARNING message with exception', () {
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    var logger = FimberLog("MYTAG");
    logger.w("Test message", ex: Exception("test error"));
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("test error"));
    assert(assertTree.lastLogLine.contains("W:MYTAG"));
  });

  test('TAGGED - log ERROR message with exception', () {
    var assertTree = AssertTree(["I", "W", "D", "E", "V"]);
    Fimber.plantTree(assertTree);
    var logger = FimberLog("MYTAG");
    logger.e("Test message", ex: Exception("test error"));
    assert(assertTree.lastLogLine.contains("Test message"));
    assert(assertTree.lastLogLine.contains("test error"));
    assert(assertTree.lastLogLine.contains("E:MYTAG"));
  });

}

class AssertTree extends LogTree {
  List<String> logLevels;
  String lastLogLine;

  AssertTree(this.logLevels);

  @override
  List<String> getLevels() {
    return logLevels;
  }

  @override
  log(String level, String msg, {String tag, Exception ex}) {
    tag = (tag??getTag());
    lastLogLine = "$level:$tag\t$msg\t$ex}";
  }
}
