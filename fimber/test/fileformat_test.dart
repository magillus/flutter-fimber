import 'dart:io';

import 'package:fimber/filename_format.dart';
import 'package:fimber/fimber.dart';
import 'package:test/test.dart';

void main() async {
  test("Format file name with date", () {
    var fileFormat = LogFileNameFormatter(format: "log_YYMMDD-HH.txt");

    expect(fileFormat.format(DateTime(2019, 01, 22, 17, 00, 00)),
        "log_190122-17.txt");

    expect(
        LogFileNameFormatter(format: "log_YY-MMMM-DD-hhaa.txt")
            .format(DateTime(2019, 12, 22, 17, 00, 00)),
        "log_19-December-22-05pm.txt");

    expect(
        LogFileNameFormatter(format: "log_YYMMDD-ddd-HH.txt")
            .format(DateTime(2019, 11, 1, 1, 00, 00)),
        "log_191101-Fri-01.txt");

    expect(
        LogFileNameFormatter.full().format(DateTime(2019, 01, 24, 13, 34, 15)),
        "log_20190124_133415.txt");
  });

  test("File date rolling test", () async {
    Fimber.clearAll();
    var logTree = TimedRollingFileTree(timeSpan: 1);
    Fimber.plantTree(logTree);
    Fimber.i("First log entry");
    var firstFile = logTree.outputFileName;
    await Future.delayed(Duration(seconds: 2))
        .then((i) => Fimber.i("Delayed log"));

    var secondFile = logTree.outputFileName;

    await Future.delayed(Duration(seconds: 1));

    print("First: $firstFile");
    print(File(firstFile).readAsStringSync());
    print("Second: $secondFile");
    print(File(secondFile).readAsStringSync());

    assert(File(firstFile).existsSync());
    assert(File(secondFile).existsSync());

    File(firstFile).deleteSync();
    File(secondFile).deleteSync();
  });

  test("Old file detection test", () async {
    Fimber.clearAll();

    // roll file every 20 bytes (in reality every log line)

    var logTree = SizeRollingFileTree(DataSize.bytes(20));
    // detection tests
    expect(logTree.isLogFile("path/test/log_1.txt"), true);
    expect(logTree.getLogIndex("path/test/log_nothing.txt"), null);
    expect(logTree.getLogIndex("path/test/log_1.txt"), 1);

    Fimber.plantTree(logTree);

    await Future.delayed(Duration(milliseconds: 200));
    Fimber.i("Log single line - A");

    await Future.delayed(Duration(milliseconds: 200));
    var logFile1 = logTree.outputFileName;
    print(logFile1);
    expect(logFile1, "log_1.txt");
    Fimber.i("Log single line - B");

    await Future.delayed(Duration(milliseconds: 200));
    var logFile2 = logTree.outputFileName;
    print(logFile2);
    expect(logFile2, "log_2.txt");
    await Future.delayed(Duration(milliseconds: 200));

    logTree = SizeRollingFileTree(DataSize.bytes(20));

    Fimber.clearAll();
    Fimber.plantTree(logTree);
    await Future.delayed(Duration(milliseconds: 200));
    Fimber.i("Log single line - C");

    var logFile3 = logTree.outputFileName;
    print(logFile3);
    expect(logFile3, "log_3.txt");

    await Future.delayed(Duration(milliseconds: 200));

    File(logFile2).deleteSync();
    File(logFile1).deleteSync();
    File(logFile3).deleteSync();
  });

  test("File size rolling test", () async {
    Fimber.clearAll();
    // roll file every 20 bytes (in reality every log line)
    var logTree = SizeRollingFileTree(DataSize.bytes(20));

    //logTree.detectFileIndex();

    await Future.delayed(Duration(milliseconds: 100));
    Fimber.plantTree(logTree);

    Fimber.i("Test log for more then limit.");
    await Future.delayed(Duration(milliseconds: 100));
    var firstFile = logTree.outputFileName;
    Fimber.i("Test log for second file");
    var secondFile = logTree.outputFileName;

    assert(firstFile != secondFile);
    print(firstFile);
    print(secondFile);
    assert(File(firstFile).existsSync());
    assert(File(secondFile).existsSync());
    await Future.delayed(Duration(seconds: 1));
    File(firstFile).deleteSync();
    File(secondFile).deleteSync();
  });

}
