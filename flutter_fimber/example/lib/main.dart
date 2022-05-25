import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fimber_io/fimber_io.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:path_provider/path_provider.dart';

void initlog() async {
  /// You can pick one of them or combine,
  /// be aware that 2 or more console loggers will output multiple times
  // Example tree of using Fimber with color logging
  Fimber.plantTree(FimberTree(useColors: true));

  /// Debug tree with time of process running
  Fimber.plantTree(DebugBufferTree.elapsed());
  /*
  var dir = await getApplicationDocumentsDirectory();
  var path = dir.path; //+"/log";
  */
  var path = '/storage/emulated/0/Documents';
  var prefix = '$path/log_';
  Fimber.d("filelog in $prefix");
  Fimber.plantTree(
      SizeRollingFileTree(DataSize.mega(5), filenamePrefix: prefix));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initlog();
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
                  } on dynamic catch (e) {
                    Fimber.w("Warning message test ${DateTime.now()}", ex: e);
                  }
                },
              ),
              TextButton(
                child: Text("LOG - WARNING with Error and stacktrace"),
                onPressed: () {
                  try {
                    throw AssertionError();
                  } on dynamic catch (e, s) {
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
