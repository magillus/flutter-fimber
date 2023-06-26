import 'package:test/test.dart';
import 'package:flutter_fimber/flutter_fimber_platform_interface.dart';
import 'package:flutter_fimber/flutter_fimber_method_channel.dart';

void main() {
  final FlutterFimberPlatform initialPlatform = FlutterFimberPlatform.instance;

  test('$MethodChannelFlutterFimber is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterFimber>());
  });
}
