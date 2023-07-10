import Flutter
import UIKit

public class SwiftFlutterFimberPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_fimber", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterFimberPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "log":
            let data = call.arguments as! NSDictionary
            let concatMessage = concatLogMessage(with: data)
            if (!concatMessage.isEmpty) {
                print(concatMessage)
            }
            result(0)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func concatLogMessage(with data: NSDictionary) -> String {
        var result: String = ""
        let message = (data["message"] as? String) ?? ""
        if (!message.isEmpty) {
            result += "\(Date())"
            
            let tag = (data["tag"] as? String) ?? "flutter"
            result += " \(tag)"
            
            let level = (data["level"] as? String) ?? "D"
            result += "/\(level)"
            
            // TODO: Disabled preFix since XCode doesn't support colorized console logging
//            let preFix = (data["preFix"] as? String) ?? ""
//            if (!preFix.isEmpty) {
//                result += "\(preFix)"
//            }
            result += " \(message)"
            
            // TODO: Disabled postFix since XCode doesn't support colorized console logging
//            let postFix = (data["postFix"] as? String) ?? ""
//            if (!postFix.isEmpty) {
//                result += "\(postFix)"
//            }
            
            let exDump = (data["ex"] as? String) ?? ""
            if (!exDump.isEmpty) {
                result += "\n\(exDump)"
            }
        }
        return result
    }
}
