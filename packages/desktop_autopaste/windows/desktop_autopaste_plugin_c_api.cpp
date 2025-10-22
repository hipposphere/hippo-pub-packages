#include "include/desktop_autopaste/desktop_autopaste_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "desktop_autopaste_plugin.h"

void DesktopAutopastePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  desktop_autopaste::DesktopAutopastePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
