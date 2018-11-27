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
        let message = data["message"] as? String?
        if (message != nil) {
            let tag = (data["tag"] as? String) ?? "flutter"
            let level = (data["level"] as? String) ?? "D"
            let exDump = (data["ex"])
            
            print("\(Date()) \(tag)/\(level):\t\(message!!)");
        }
        result(0)
    } catch {
        result(-1)
    }
  }
}
