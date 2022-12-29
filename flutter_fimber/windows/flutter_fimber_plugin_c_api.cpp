#include "include/flutter_fimber/flutter_fimber_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_fimber_plugin.h"

void FlutterFimberPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_fimber::FlutterFimberPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
