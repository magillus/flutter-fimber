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
}
