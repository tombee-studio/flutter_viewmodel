#include "include/flutter_viewmodel/flutter_viewmodel_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define FLUTTER_VIEWMODEL_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_viewmodel_plugin_get_type(), \
                              FlutterViewmodelPlugin))

struct _FlutterViewmodelPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FlutterViewmodelPlugin, flutter_viewmodel_plugin, g_object_get_type())

static void flutter_viewmodel_plugin_handle_method_call(
    FlutterViewmodelPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;
  response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_viewmodel_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_viewmodel_plugin_parent_class)->dispose(object);
}

static void flutter_viewmodel_plugin_class_init(FlutterViewmodelPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_viewmodel_plugin_dispose;
}

static void flutter_viewmodel_plugin_init(FlutterViewmodelPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlutterViewmodelPlugin* plugin = FLUTTER_VIEWMODEL_PLUGIN(user_data);
  flutter_viewmodel_plugin_handle_method_call(plugin, method_call);
}

void flutter_viewmodel_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterViewmodelPlugin* plugin = FLUTTER_VIEWMODEL_PLUGIN(
      g_object_new(flutter_viewmodel_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "flutter_viewmodel",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
