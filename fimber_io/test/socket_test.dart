import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber_io/fimber_io.dart';
import 'package:test/test.dart';

void main() async {
  var testPort = 17779;

  group('UDP Socket log tests.', () {
    NetworkLoggingTree logTree;

    var logMessages = <String>[];
    late RawDatagramSocket testReceiveSocket;

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

      logTree = NetworkLoggingTree.udp('127.0.0.1', testPort);

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

    test('Test UDP socket logger', () async {
      Fimber.i('test log out1');

      await Future.delayed(Duration(milliseconds: 100));

      expect(1, logMessages.length);
      expect(true, logMessages.last.contains('test log out1'));
    });
  });

  group('TCP Socket log tests.', () {
    var logMessages = <String>[];
    late ServerSocket testReceiveSocket;
    late StreamSubscription socketSubscription;
    late StreamSubscription clientSubscription;

    setUp(() async {
      Fimber.clearAll();
      testReceiveSocket =
          await ServerSocket.bind(InternetAddress.anyIPv4, testPort);

      print('Datagram socket ready to receive');
      print('${testReceiveSocket.address.address}:${testReceiveSocket.port}');

      socketSubscription = testReceiveSocket.listen((client) {
        print('Socket connected. $client');
        clientSubscription = client.listen((event) {
          var message = utf8.decoder.convert(event);
          logMessages.add(message);
        }, onError: (t) => print('Error with socket ' + t));
      }, onDone: () => print('Socket client disconnected.'));

      print('Delay to start sockets');
      await Future.delayed(Duration(milliseconds: 100));

      print('Test Setup complete.');
    });

    tearDown(() {
      clientSubscription.cancel();
      socketSubscription.cancel();
      testReceiveSocket.close();
      print('TearDown.');
    });

    test('Test TCP socket logger', () async {
      var logTree = NetworkLoggingTree.tcp('127.0.0.1', testPort);

      Fimber.plantTree(logTree);
      Fimber.i('test log out2');

      await Future.delayed(Duration(milliseconds: 100));

      expect(1, logMessages.length);
      expect(true, logMessages.last.contains('test log out2'));

      Fimber.clearAll();
      // TODO fix stalled test - it doesn't exit
    });

    // test('Test TCP not available socket logger', () async {
    //   var logTree =
    //       NetworkLoggingTree('127.0.0.1', testPort + 1, isTcpSocket: true);
    //   Fimber.plantTree(logTree);

    //   Fimber.i('test log out3');
    //   Fimber.clearAll();
    // });
  });
}
