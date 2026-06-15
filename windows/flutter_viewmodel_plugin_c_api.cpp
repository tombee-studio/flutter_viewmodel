#include "include/flutter_viewmodel/flutter_viewmodel_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_viewmodel_plugin.h"

void FlutterViewmodelPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_viewmodel::FlutterViewmodelPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
