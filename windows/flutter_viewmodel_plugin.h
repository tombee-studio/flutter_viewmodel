#ifndef FLUTTER_PLUGIN_FLUTTER_VIEWMODEL_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_VIEWMODEL_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_viewmodel {

class FlutterViewmodelPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterViewmodelPlugin();

  virtual ~FlutterViewmodelPlugin();

  FlutterViewmodelPlugin(const FlutterViewmodelPlugin&) = delete;
  FlutterViewmodelPlugin& operator=(const FlutterViewmodelPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_viewmodel

#endif  // FLUTTER_PLUGIN_FLUTTER_VIEWMODEL_PLUGIN_H_
