#include "desktop_permissions_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace desktop_permissions {

// static
void DesktopPermissionsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "desktop_permissions",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<DesktopPermissionsPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

DesktopPermissionsPlugin::DesktopPermissionsPlugin() {}

DesktopPermissionsPlugin::~DesktopPermissionsPlugin() {}

void DesktopPermissionsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  // On Windows, no special permissions are required for keyboard hooks
  // or input simulation, so all permission checks return true/granted
  
  if (method_call.method_name() == "isAccessibilityGranted") {
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "requestAccessibility") {
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "getAccessibilityStatus") {
    result->Success(flutter::EncodableValue("notRequired"));
  } else if (method_call.method_name() == "isInputMonitoringGranted") {
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "requestInputMonitoring") {
    result->Success(flutter::EncodableValue(true));
  } else if (method_call.method_name() == "getInputMonitoringStatus") {
    result->Success(flutter::EncodableValue("notRequired"));
  } else {
    result->NotImplemented();
  }
}

}  // namespace desktop_permissions
