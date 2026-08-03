#include "include/native_natural_sort/native_natural_sort_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "native_natural_sort_plugin.h"

void NativeNaturalSortPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  native_natural_sort::NativeNaturalSortPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
