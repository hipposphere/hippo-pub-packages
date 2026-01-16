#ifndef FLUTTER_PLUGIN_DESKTOP_PERMISSIONS_PLUGIN_H_
#define FLUTTER_PLUGIN_DESKTOP_PERMISSIONS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace desktop_permissions {

class DesktopPermissionsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DesktopPermissionsPlugin();

  virtual ~DesktopPermissionsPlugin();

  // Disallow copy and assign.
  DesktopPermissionsPlugin(const DesktopPermissionsPlugin&) = delete;
  DesktopPermissionsPlugin& operator=(const DesktopPermissionsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace desktop_permissions

#endif  // FLUTTER_PLUGIN_DESKTOP_PERMISSIONS_PLUGIN_H_
