#include "include/app_permissions/app_permissions_plugin.h"

#include <cstring>

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#define APP_PERMISSIONS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), app_permissions_plugin_get_type(), \
                               AppPermissionsPlugin))

struct _AppPermissionsPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(AppPermissionsPlugin, app_permissions_plugin, g_object_get_type())

static FlMethodResponse* success_bool(bool value) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(
      fl_value_new_bool(value)));
}

static FlMethodResponse* success_string(const gchar* value) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(
      fl_value_new_string(value)));
}

static void app_permissions_plugin_handle_method_call(
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = success_string("Linux");
  } else if (strcmp(method, "isAccessibilityGranted") == 0) {
    response = success_bool(true);
  } else if (strcmp(method, "requestAccessibility") == 0) {
    response = success_bool(true);
  } else if (strcmp(method, "getAccessibilityStatus") == 0) {
    response = success_string("notRequired");
  } else if (strcmp(method, "isInputMonitoringGranted") == 0) {
    response = success_bool(true);
  } else if (strcmp(method, "requestInputMonitoring") == 0) {
    response = success_bool(true);
  } else if (strcmp(method, "getInputMonitoringStatus") == 0) {
    response = success_string("notRequired");
  } else if (strcmp(method, "isMicrophoneGranted") == 0) {
    response = success_bool(true);
  } else if (strcmp(method, "requestMicrophone") == 0) {
    response = success_bool(true);
  } else if (strcmp(method, "getMicrophoneStatus") == 0) {
    response = success_string("notRequired");
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void app_permissions_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(app_permissions_plugin_parent_class)->dispose(object);
}

static void app_permissions_plugin_class_init(AppPermissionsPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = app_permissions_plugin_dispose;
}

static void app_permissions_plugin_init(AppPermissionsPlugin* self) {
  (void)self;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  (void)channel;
  (void)user_data;
  app_permissions_plugin_handle_method_call(method_call);
}

void app_permissions_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  AppPermissionsPlugin* plugin = APP_PERMISSIONS_PLUGIN(
      g_object_new(app_permissions_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "app_permissions",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
