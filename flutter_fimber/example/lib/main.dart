import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

void main() {
  /// You can pick one of them or combine,
  /// be aware that 2 or more console loggers will output multiple times
  // Example tree of using Fimber with color logging
  Fimber.plantTree(FimberTree(useColors: true));

  /// Debug tree with time of process running
  Fimber.plantTree(DebugBufferTree.elapsed());
  runApp(MyApp());
}

/// Example app for showing usage of Fimber
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fimber Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Fimber test'),
              TextButton(
                child: Text("LOG - ERROR"),
                onPressed: () {
                  Fimber.e("Error message test ${DateTime.now()}");
                },
              ),
              TextButton(
                child: Text("LOG - INFO"),
                onPressed: () {
                  Fimber.i("Info message test ${DateTime.now()}");
                },
              ),
              TextButton(
                child: Text("LOG - DEBUG"),
                onPressed: () {
                  Fimber.d("Debug message test ${DateTime.now()}");
                },
              ),
              TextButton(
                child: Text("LOG - WARNING with exception"),
                onPressed: () {
                  try {
                    throw Exception("Test exception here");
                  } on Exception catch (e) {
                    Fimber.w("Warning message test ${DateTime.now()}", ex: e);
                  }
                },
              ),
              TextButton(
                child: Text("LOG - WARNING with Error and stacktrace"),
                onPressed: () {
                  try {
                    throw AssertionError();
                  } on AssertionError catch (e, s) {
                    Fimber.w("Warning message test ${DateTime.now()}",
                        ex: e, stacktrace: s);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
