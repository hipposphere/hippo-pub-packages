#include "include/app_permissions/app_permissions_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "app_permissions_plugin.h"

void AppPermissionsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  app_permissions::AppPermissionsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
