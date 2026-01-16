#include "include/desktop_permissions/desktop_permissions_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "desktop_permissions_plugin.h"

void DesktopPermissionsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  desktop_permissions::DesktopPermissionsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
