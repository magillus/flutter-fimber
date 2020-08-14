import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../fimber_io.dart';

/// Terminal
/// nc -kvl 5601 | grep TheClassName
class NetworkLoggingTree extends CustomFormatTree implements UnPlantableTree {
  /// Internal constructor to start socket.
  NetworkLoggingTree(this._server, this._port,
      {this.timeout = const Duration(seconds: 10)})
      : super(
          useColors: true,
          logFormat:
              '${CustomFormatTree.levelToken} ${CustomFormatTree.tagToken}: ${CustomFormatTree.messageToken}',
        );

  final Duration timeout;
  final String _server;
  final int _port;

  Completer<RawDatagramSocket> _socketComplete;
  RawDatagramSocket _socket;

  @override
  void planted() {
    // start socket and listen
    if (_socketComplete == null) {
      _socketComplete = Completer();
      print('Socket about to open.');
      _socketComplete.future.then((value) {
        print('Socket opened. $value');
        return _socket = value;
      });
      _socketComplete.complete(RawDatagramSocket.bind(
        _server,
        0,// use any available port
      ));
    }
  }

  @override
  void unplanted() {
    _socket?.close();
    _socketComplete = null;
    _socket = null;
  }

  @override
  void printLine(String line, {String level}) {
    super.printLine(line, level: level);
    if (_socket != null) {
      var bytesToSend = utf8.encoder.convert(line).toList();
      print('socket available - will send: ${bytesToSend.length}');
      _socket.send(bytesToSend, InternetAddress(_server), _port);
    } else {
      print('No socket available - will wait for one with this message.');
      _socketComplete.future.then((value) => value.send(
          utf8.encoder.convert(line).toList(),
          InternetAddress(_server),
          _port));
      // super.printLine(
      //     'Socket not available: $_server : $_port to send logs.'); //todo add error level
    }
  }
}
