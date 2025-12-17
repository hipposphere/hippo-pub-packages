#ifndef FLUTTER_PLUGIN_HID_API_PLUGIN_H_
#define FLUTTER_PLUGIN_HID_API_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <map>
#include <string>
#include <windows.h>

namespace hid_api {

class HidApiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  HidApiPlugin();

  virtual ~HidApiPlugin();

  // Disallow copy and assign.
  HidApiPlugin(const HidApiPlugin&) = delete;
  HidApiPlugin& operator=(const HidApiPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  std::map<std::string, HANDLE> open_devices_;
};

}  // namespace hid_api

#endif  // FLUTTER_PLUGIN_HID_API_PLUGIN_H_
