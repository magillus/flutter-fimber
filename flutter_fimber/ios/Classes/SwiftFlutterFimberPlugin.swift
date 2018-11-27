import Flutter
import UIKit

public class SwiftFlutterFimberPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_fimber", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterFimberPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "log" else {
        result(FlutterMethodNotImplemented)
        return
    }
    do {
     
        let data = call.arguments as! NSDictionary
        print("level = ", data["level"])//["level"])
        print("message = ", data["message"])
        print("tag = ", data["tag"])
        //print("tag: %s", t0)
        //    print("level: %s", tag.level)
        result(0)
    } catch {
        result(-1)
    }
  }
}
