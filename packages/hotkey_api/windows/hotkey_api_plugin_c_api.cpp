#include "include/hotkey_api/hotkey_api_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "hotkey_api_plugin.h"

void HotkeyApiPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  hotkey_api::HotkeyApiPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
