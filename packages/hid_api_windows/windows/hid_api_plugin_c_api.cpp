#include "include/hid_api_windows/hid_api_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "hid_api_plugin.h"

void HidApiPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  hid_api::HidApiPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
