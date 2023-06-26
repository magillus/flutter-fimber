import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_fimber/flutter_fimber_method_channel.dart';
import 'package:test/test.dart';

void main() {
  MethodChannelFlutterFimber platform = MethodChannelFlutterFimber();
  const MethodChannel channel = MethodChannel('flutter_fimber');

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();

    channel.setMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
