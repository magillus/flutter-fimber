import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:flutter_fimber/flutter_fimber_platform_interface.dart';
import 'package:flutter_fimber/flutter_fimber_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterFimberPlatform
    with MockPlatformInterfaceMixin
    implements FlutterFimberPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterFimberPlatform initialPlatform = FlutterFimberPlatform.instance;

  test('$MethodChannelFlutterFimber is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterFimber>());
  });

  test('getPlatformVersion', () async {
    FlutterFimber flutterFimberPlugin = FlutterFimber();
    MockFlutterFimberPlatform fakePlatform = MockFlutterFimberPlatform();
    FlutterFimberPlatform.instance = fakePlatform;

    expect(await flutterFimberPlugin.getPlatformVersion(), '42');
  });
}
