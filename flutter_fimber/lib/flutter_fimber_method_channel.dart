import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_fimber_platform_interface.dart';

/// An implementation of [FlutterFimberPlatform] that uses method channels.
class MethodChannelFlutterFimber extends FlutterFimberPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_fimber');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
