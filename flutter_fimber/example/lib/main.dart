import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

void main() {
  Fimber.plantTree(FimberTree());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TargetPlatform platform;

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
    platform = Theme
        .of(context)
        .platform;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Fimber on on: $platform\n'),
              FlatButton(
                child: Text("LOG - ERROR"),
                onPressed: () {
                  Fimber.e("Error message test ${DateTime.now()}");
                },
              ),
              FlatButton(
                child: Text("LOG - INFO"),
                onPressed: () {
                  Fimber.i("Info message test ${DateTime.now()}");
                },
              ),
              FlatButton(
                child: Text("LOG - DEBUG"),
                onPressed: () {
                  Fimber.d("Debug message test ${DateTime.now()}");
                },
              ),
              FlatButton(
                child: Text("LOG - WARNING with exception"),
                onPressed: () {
                  try {
                    throw Exception("Test exception here");
                  } catch (e) {
                    Fimber.w("Warning message test ${DateTime.now()}", ex: e);
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
