//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <desktop_autopaste/desktop_autopaste_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) desktop_autopaste_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DesktopAutopastePlugin");
  desktop_autopaste_plugin_register_with_registrar(desktop_autopaste_registrar);
}
