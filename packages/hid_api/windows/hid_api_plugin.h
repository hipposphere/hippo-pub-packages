#ifndef FLUTTER_PLUGIN_HID_API_PLUGIN_H_
#define FLUTTER_PLUGIN_HID_API_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <map>
#include <string>
#include <windows.h>

namespace hid_api {

class HidApiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  HidApiPlugin(flutter::BinaryMessenger* messenger);

  virtual ~HidApiPlugin();

  // Disallow copy and assign.
  HidApiPlugin(const HidApiPlugin&) = delete;
  HidApiPlugin& operator=(const HidApiPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  flutter::EncodableList GetDeviceList();

 private:
  flutter::BinaryMessenger* messenger_;
  std::map<std::string, HANDLE> open_devices_;
  std::map<std::string, std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>> event_channels_;
  std::map<std::string, std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>> disconnection_channels_;
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> device_update_channel_;
};

}  // namespace hid_api

#endif  // FLUTTER_PLUGIN_HID_API_PLUGIN_H_
