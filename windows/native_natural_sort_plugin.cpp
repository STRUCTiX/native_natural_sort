#include "native_natural_sort_plugin.h"

#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace native_natural_sort {

// static
void NativeNaturalSortPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<NativeNaturalSortPlugin>();

  CollationHostApi::SetUp(registrar->messenger(), plugin->collation_plugin_.get());

  registrar->AddPlugin(std::move(plugin));
}

NativeNaturalSortPlugin::NativeNaturalSortPlugin()
    : collation_plugin_(std::make_unique<CollationPlugin>()) {}

NativeNaturalSortPlugin::~NativeNaturalSortPlugin() {}

}  // namespace native_natural_sort
