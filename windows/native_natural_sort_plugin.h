#ifndef FLUTTER_PLUGIN_NATIVE_NATURAL_SORT_PLUGIN_H_
#define FLUTTER_PLUGIN_NATIVE_NATURAL_SORT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace native_natural_sort {

class NativeNaturalSortPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  NativeNaturalSortPlugin();

  virtual ~NativeNaturalSortPlugin();

  // Disallow copy and assign.
  NativeNaturalSortPlugin(const NativeNaturalSortPlugin&) = delete;
  NativeNaturalSortPlugin& operator=(const NativeNaturalSortPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace native_natural_sort

#endif  // FLUTTER_PLUGIN_NATIVE_NATURAL_SORT_PLUGIN_H_
