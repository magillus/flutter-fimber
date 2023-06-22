import 'dart:async';
import 'dart:io';

import 'package:fimber_io/fimber_io.dart';
import 'package:test/test.dart';

void main() async {
  final dirSeparator = Platform.pathSeparator;

  group('File logs.', () {
    const testDirName = 'test_logs';
    final logDir = Directory(testDirName);

    setUp(() {
      Fimber.clearAll();
      logDir.createSync(recursive: true);
    });
    tearDown(() {
      if (logDir.existsSync()) {
        logDir.deleteSync(recursive: true);
      }
      Fimber.clearAll();
    });

    test('File output logger', () async {
      final filePath = '$testDirName${dirSeparator}test-output.logger.log.txt';
      final file = File(filePath);
      Fimber.clearAll();
      Fimber.plantTree(FimberFileTree(filePath));

      Fimber.i('Test log');

      await Future.delayed(const Duration(seconds: 1));

      final lines = file.readAsLinesSync();
      print('File: ${file.absolute}');
      expect(lines.length, 1);
      expect(
        'Test log',
        lines[0].substring('2019-02-03T07:19:59.417122'.length + 1),
      );
    });

    test('Time format detection', () async {
      final filePath =
          '$testDirName${dirSeparator}test-format-detection.log.txt';
      Fimber.clearAll();
      Fimber.plantTree(
        FimberFileTree(
          filePath,
          logFormat:
              '${CustomFormatTree.timeElapsedToken} ${CustomFormatTree.messageToken} ${CustomFormatTree.timeStampToken}',
        ),
      );

      Fimber.i('Test log');

      await Future.delayed(const Duration(seconds: 1));
      final file = File(filePath);
      final lines = file.readAsLinesSync();
      print('File: ${file.absolute}');
      assert(lines.length == 1);
      expect(
        lines[0].substring(
          '0:00:00.008303'.length + 1,
          lines[0].length - ' 2019-01-22T06:51:58.062997'.length,
        ),
        'Test log',
      );
    });

    test('Directory autocreate.', () async {
      final logTreeDir = Directory('$testDirName${dirSeparator}_2');
      expect(logTreeDir.existsSync(), false);
      final fileTree =
          FimberFileTree('${logTreeDir.path}${dirSeparator}log_test.log');
      Fimber.plantTree(fileTree);
      Fimber.i('Test log entry');
      await Future.delayed(const Duration(milliseconds: 2000));
      expect(logTreeDir.existsSync(), true);
    });

    test('File log with buffer overflow', () async {
      final fileTree = FimberFileTree(
        '$testDirName${dirSeparator}log_buffer_overflow ${DateTime.now().millisecondsSinceEpoch}.log',
      );
      Fimber.plantTree(fileTree);
      final text500B = List.filled(50, '1234567890').join();
      Fimber.i('Test log: $text500B');
      Fimber.i('Test log: $text500B');
      await Future.delayed(const Duration(milliseconds: 50));
      Fimber.i('Test log: $text500B');
      Fimber.i('Test log: $text500B');
      await Future.delayed(const Duration(milliseconds: 50));
      Fimber.i('Test log: $text500B');
      Fimber.i('Test log: $text500B');
      fileTree.close(); // cut the file buffer flush every 500ms
      final fileSize = File(fileTree.outputFileName).lengthSync();
      assert(fileSize > 2 * 1038); // more then 1 line 1000chars + log tag/date
      assert(fileSize < 3 * 1038); // less then 3 kb
      // - last log entry in buffer wasn't flushed to disk yet
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('File date rolling test', () async {
      print('Detect waittime: +300 : ${DateTime.now()}');
      final waitForRightTime =
          2000 - (DateTime.now().millisecondsSinceEpoch % 2000);
      print('Waiting for start time: $waitForRightTime : ${DateTime.now()}');
      await Future.delayed(Duration(milliseconds: waitForRightTime + 00))
          .then((i) {});
      print('Done waiting : ${DateTime.now()}');
      final logTree = TimedRollingFileTree(
        timeSpan: 2,
        filenamePrefix: '$testDirName${dirSeparator}log_test_rolling_',
      );
      Fimber.plantTree(logTree);
      Fimber.i('First log entry');
      Fimber.i('First log entry #2');

      final firstFile = logTree.outputFileName;

      // still same file
      await Future.delayed(const Duration(milliseconds: 1200)).then((i) {
        Fimber.i('Delayed log in one second');
        Fimber.i('Delayed log in one second #2');
      });

      await Future.delayed(const Duration(seconds: 3)).then((i) {
        Fimber.i('Delayed log');
        Fimber.i('Delayed log #2');
      });

      // wait until buffer dumps to file
      await waitForAppendBuffer();

      await Future.delayed(const Duration(milliseconds: 100));

      final secondFile = logTree.outputFileName;

      await Future.delayed(const Duration(milliseconds: 100));
      // wait until buffer dumps to file
      await waitForAppendBuffer();
      print(firstFile);
      print(File(firstFile).readAsStringSync());
      print(secondFile);
      print(File(secondFile).readAsStringSync());

      expect(File(firstFile).readAsStringSync().trim().split('\n').length, 4);

      expect(File(secondFile).readAsStringSync().trim().split('\n').length, 2);

      assert(firstFile != secondFile);
      assert(File(firstFile).existsSync());
      assert(File(secondFile).existsSync());

      File(firstFile).deleteSync();
      File(secondFile).deleteSync();
    });
    test('Format file name with date', () {
      final fileFormat =
          LogFileNameFormatter(filenameFormat: 'log_YYMMDD-HH.txt');

      expect(
        fileFormat.format(DateTime(2019, 01, 22, 17, 00, 00)),
        'log_190122-17.txt',
      );

      expect(
        LogFileNameFormatter(filenameFormat: 'log_YY-MMMM-DD-hhaa.txt')
            .format(DateTime(2019, 12, 22, 17, 00, 00)),
        'log_19-December-22-05pm.txt',
      );

      expect(
        LogFileNameFormatter(filenameFormat: 'log_YYMMDD-ddd-HH.txt')
            .format(DateTime(2019, 11, 1, 1, 00, 00)),
        'log_191101-Fri-01.txt',
      );

      expect(
        LogFileNameFormatter.full().format(DateTime(2019, 01, 24, 13, 34, 15)),
        'log_20190124_133415.txt',
      );
    });

    test('No old file detection test', () async {
      final logTree = SizeRollingFileTree(
        DataSize.bytes(20),
        filenamePrefix: '$testDirName${dirSeparator}empty${dirSeparator}log_',
      );

      final logFile = logTree.outputFileName;
      // detects if file was created
      expect(
        logTree.isLogFile(
          '$testDirName${dirSeparator}empty${dirSeparator}log_1.txt',
        ),
        true,
      );

      Fimber.plantTree(logTree);

      await Future.delayed(const Duration(milliseconds: 200));
      Fimber.i('Log single line - A');
      await waitForAppendBuffer();

      File(logFile).deleteSync();
    });

    test('Old file detection test', () async {
      // roll file every 20 bytes (in reality every log line)
      final logTree = SizeRollingFileTree(
        DataSize.bytes(20),
        filenamePrefix: '$testDirName${dirSeparator}log_',
      );
      // detection tests - todo fix
      expect(logTree.isLogFile('$testDirName${dirSeparator}log_1.txt'), true);
      expect(
        logTree.getLogIndex('$testDirName${dirSeparator}log_nothing.txt'),
        -1,
      );
      expect(logTree.getLogIndex('$testDirName${dirSeparator}log_1.txt'), 1);
      expect(logTree.getLogIndex('$testDirName${dirSeparator}log_3.txt'), 3);

      Fimber.plantTree(logTree);

      await Future.delayed(const Duration(milliseconds: 200));
      Fimber.i('Log single line - A');
      await waitForAppendBuffer();

      await Future.delayed(const Duration(milliseconds: 200));
      final logFile1 = logTree.outputFileName;

      print(logFile1);
      expect(logFile1, '$testDirName${dirSeparator}log_1.txt');
      Fimber.i('Log single line - B');
      await waitForAppendBuffer();
      await Future.delayed(const Duration(milliseconds: 200));
      final logFile2 = logTree.outputFileName;

      print(logFile2);
      expect(logFile2, '$testDirName${dirSeparator}log_2.txt');

      await Future.delayed(const Duration(milliseconds: 200));
      Fimber.i('Log single line - C with some chars');
      await waitForAppendBuffer();

      final logFile3 = logTree.outputFileName;
      print(logFile3);
      expect(logFile3, '$testDirName${dirSeparator}log_3.txt');

      Fimber.i('add some new');
      await Future.delayed(const Duration(milliseconds: 200));

      File(logFile2).deleteSync();
      File(logFile1).deleteSync();
      File(logFile3).deleteSync();
    });

    test('File size rolling test', () async {
      // roll file every 20 bytes (in reality every log line)
      final logTree = SizeRollingFileTree(
        DataSize.bytes(20),
        filenamePrefix: '$testDirName$dirSeparator',
      );

      //logTree.detectFileIndex();

      await Future.delayed(const Duration(milliseconds: 100));
      Fimber.plantTree(logTree);

      Fimber.i('Test log for more then limit.');
      // wait until buffer dumps to file
      await waitForAppendBuffer();

      final firstFile = logTree.outputFileName;
      Fimber.i('Test log for second file');
      // wait until buffer dumps to file
      await waitForAppendBuffer();

      final secondFile = logTree.outputFileName;

      assert(firstFile != secondFile);
      print(firstFile);
      print(secondFile);
      assert(File(firstFile).existsSync());
      assert(File(secondFile).existsSync());

      await Future.delayed(const Duration(seconds: 1));

      File(firstFile).deleteSync();
      File(secondFile).deleteSync();
    });

    test('File Tree - append test', () async {
      final logFile = '$testDirName${dirSeparator}test.multilog.txt';

      Fimber.plantTree(FimberFileTree.elapsed(logFile));

      await Future.delayed(const Duration(milliseconds: 100));

      Fimber.i('Test log line 1.');
      Fimber.i('Test log line 2.');
      await Future.delayed(const Duration(milliseconds: 100));
      Fimber.i('Test log line 3.');
      // wait until buffer dumps to file
      await waitForAppendBuffer();

      final logLines = await File(logFile).readAsLines();
      expect(logLines.length, 3);
      assert(logLines[0].endsWith('Test log line 1.'));
      assert(logLines[1].endsWith('Test log line 2.'));
      assert(logLines[2].endsWith('Test log line 3.'));
    });

    test('File Tree - Rolling time append test', () async {
      final logLevels = CustomFormatTree.defaultLevels.toList();
      logLevels.remove('D');
      final tree = TimedRollingFileTree(
        filenamePrefix: '$testDirName${dirSeparator}mul_tree_time_append',
        logLevels: logLevels,
      );
      // todo test file name generation
      Fimber.plantTree(tree);
      await Future.delayed(const Duration(milliseconds: 100));
      Fimber.i('Test log line 1.');
      Fimber.d('Test log line 1.'); // should be ignored
      //todo test order of adding lines - remove the delays
      await Future.delayed(const Duration(milliseconds: 10));
      Fimber.i('Test log line 2.');
      await Future.delayed(const Duration(milliseconds: 100));
      Fimber.i('Test log line 3.');
      // wait until buffer dumps to file
      await waitForAppendBuffer();

      final logFile = tree.outputFileName;
      final logLines = await File(logFile).readAsLines();

      expect(logLines.length, 3);
      assert(logLines[0].endsWith('Test log line 1.'));
      assert(logLines[1].endsWith('Test log line 2.'));
      assert(logLines[2].endsWith('Test log line 3.'));
    });
  });
}

/// Waits for append buffer method.
Future waitForAppendBuffer() async {
  await Future.delayed(
    const Duration(milliseconds: FimberFileTree.fileBufferFlushInterval),
  );
}
