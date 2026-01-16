#ifndef FLUTTER_PLUGIN_APP_PERMISSIONS_PLUGIN_H_
#define FLUTTER_PLUGIN_APP_PERMISSIONS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace app_permissions {

class AppPermissionsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AppPermissionsPlugin();

  virtual ~AppPermissionsPlugin();

  // Disallow copy and assign.
  AppPermissionsPlugin(const AppPermissionsPlugin&) = delete;
  AppPermissionsPlugin& operator=(const AppPermissionsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace app_permissions

#endif  // FLUTTER_PLUGIN_APP_PERMISSIONS_PLUGIN_H_
