#ifndef FLUTTER_PLUGIN_NATIVE_NATURAL_SORT_PLUGIN_H_
#define FLUTTER_PLUGIN_NATIVE_NATURAL_SORT_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "collation_plugin.h"

namespace native_natural_sort {

class NativeNaturalSortPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  NativeNaturalSortPlugin();

  virtual ~NativeNaturalSortPlugin();

  // Disallow copy and assign.
  NativeNaturalSortPlugin(const NativeNaturalSortPlugin&) = delete;
  NativeNaturalSortPlugin& operator=(const NativeNaturalSortPlugin&) = delete;

 private:
  std::unique_ptr<CollationPlugin> collation_plugin_;
};

}  // namespace native_natural_sort

#endif  // FLUTTER_PLUGIN_NATIVE_NATURAL_SORT_PLUGIN_H_
