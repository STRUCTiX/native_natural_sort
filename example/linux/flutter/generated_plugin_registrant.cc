//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <native_natural_sort/native_natural_sort_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) native_natural_sort_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NativeNaturalSortPlugin");
  native_natural_sort_plugin_register_with_registrar(native_natural_sort_registrar);
}
