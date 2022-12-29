import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_fimber_method_channel.dart';

abstract class FlutterFimberPlatform extends PlatformInterface {
  /// Constructs a FlutterFimberPlatform.
  FlutterFimberPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFimberPlatform _instance = MethodChannelFlutterFimber();

  /// The default instance of [FlutterFimberPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterFimber].
  static FlutterFimberPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterFimberPlatform] when
  /// they register themselves.
  static set instance(FlutterFimberPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
