import 'dart:convert';
import 'dart:io';

import 'package:fimber_io/fimber_io.dart';
import 'package:test/test.dart';

void main() async {
  var testPort = 17779;

  group('Socket log tests.', () {
    NetworkLoggingTree logTree;

    var logMessages = <String>[];
    RawDatagramSocket testReceiveSocket;

    setUp(() async {
      Fimber.clearAll();
      testReceiveSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, testPort);

      print('Datagram socket ready to receive');
      print('${testReceiveSocket.address.address}:${testReceiveSocket.port}');
      testReceiveSocket.listen((RawSocketEvent e) {
        print('Socket event: $e');
        var d = testReceiveSocket.receive();        
        if (d == null) return;
        var message = utf8.decoder.convert(d.data);
        logMessages.add(message);
      }, onError: (t) => print('Error with socket ' + t));

      logTree = NetworkLoggingTree('127.0.0.1', testPort);

      Fimber.plantTree(logTree);
      print('Delay to start sockets');
      await Future.delayed(Duration(milliseconds: 100));

      print('Test Setup complete.');
    });

    tearDown(() {
      testReceiveSocket.close();
      Fimber.clearAll();
      print('TearDown.');
    });

    test('File output logger', () async {
      Fimber.i('test log out1');

      await Future.delayed(Duration(milliseconds: 100));

      expect(1, logMessages.length);
      expect(true, logMessages.last.contains('test log out1'));
    });
  });
}
