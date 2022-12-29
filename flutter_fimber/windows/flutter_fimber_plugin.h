#ifndef FLUTTER_PLUGIN_FLUTTER_FIMBER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_FIMBER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_fimber {

class FlutterFimberPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterFimberPlugin();

  virtual ~FlutterFimberPlugin();

  // Disallow copy and assign.
  FlutterFimberPlugin(const FlutterFimberPlugin&) = delete;
  FlutterFimberPlugin& operator=(const FlutterFimberPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_fimber

#endif  // FLUTTER_PLUGIN_FLUTTER_FIMBER_PLUGIN_H_
