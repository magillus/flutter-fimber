import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../fimber_io.dart';

/// NetworkLoggingTree uses TCP or UDP sockets to send log entries to.
///
/// Example in terminal:
/// nc -kvl 5601 | grep TheClassName
class NetworkLoggingTree extends CustomFormatTree implements UnPlantableTree {
  /// Creates isntance of [NetworkLoggingTree]
  NetworkLoggingTree._(this._server, this._port,
      {this.timeout = const Duration(seconds: 10), this.isTcpSocket = false})
      : super(
          useColors: true,
          logFormat:
              '${CustomFormatTree.levelToken} ${CustomFormatTree.tagToken}: ${CustomFormatTree.messageToken}',
        );

  /// Creates UDP version of the [NetworkLoggingTree]
  factory NetworkLoggingTree.udp(String server, int port) =>
      NetworkLoggingTree._(server, port);

  /// Creates TCP version of the [NetworkLoggingTree]
  factory NetworkLoggingTree.tcp(String server, int port) =>
      NetworkLoggingTree._(server, port, isTcpSocket: true);

  /// Connection timeout (used on TCP socket)
  final Duration timeout;
  final String _server;
  final int _port;

  /// If true it is TCP socket to be used.
  final bool isTcpSocket;

  Completer<RawDatagramSocket>? _socketUdpComplete;
  Completer<Socket>? _socketTcpComplete;
  RawDatagramSocket? _socketUdp;
  Socket? _socket;

  @override
  void planted() {
    // start socket and listen
    if (isTcpSocket) {
      _prepareTcpSocket();
    } else {
      _prepareUdpSocket();
    }
  }

  void _prepareUdpSocket() {
    if (_socketUdpComplete == null) {
      _socketUdpComplete = Completer();
      print('UDP Socket about to open.');
      _socketUdpComplete?.future.then((value) {
        print('Socket opened. $value');
        _socketUdp = value;
      });
      _socketUdpComplete?.complete(RawDatagramSocket.bind(
        _server,
        0, // use any available port
      ));
    }
  }

  void _prepareTcpSocket() {
    if (_socketTcpComplete == null) {
      _socketTcpComplete = Completer();
      print('TCP Socket about to open.');
      _socketTcpComplete?.future.then((value) {
        print('TCP Socket opened. $value');
        _socket = value;
      });
      _socketTcpComplete
          ?.complete(Socket.connect(_server, _port, timeout: timeout));
    }
  }

  @override
  void unplanted() {
    _socket?.close();
    _socketTcpComplete = null;
    _socket = null;
    _socketUdp?.close();
    _socketUdpComplete = null;
    _socketUdp = null;
  }

  @override
  void printLine(String line, {String? level}) {
    super.printLine(line, level: level);
    if (isTcpSocket) {
      if (_socket != null) {
        print('TCP socket available - will send: ${line.length}');
        _socket?.writeln(line);
      } else {
        print('No socket available - will wait for one with this message.');
        _socketTcpComplete?.future.then((value) => value.writeln(line));
      }
    } else {
      if (_socketUdp != null) {
        var bytesToSend = utf8.encoder.convert(line).toList();
        print('UDP socket available - will send: ${bytesToSend.length}');
        _socketUdp?.send(bytesToSend, InternetAddress(_server), _port);
      } else {
        print('No socket available - will wait for one with this message.');

        /// TODO make a small cache locally before socket is available
        _socketUdpComplete?.future.then((value) => value.send(
            utf8.encoder.convert(line).toList(),
            InternetAddress(_server),
            _port));
      }
    }
  }
}
