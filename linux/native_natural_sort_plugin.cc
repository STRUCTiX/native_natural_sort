#include "include/native_natural_sort/native_natural_sort_plugin.h"

#include <flutter_linux/flutter_linux.h>

// Linux uses Dart FFI (collation_ffi_linux.dart) to load system libicui18n
// directly — no MethodChannel needed. This file keeps minimal Flutter plugin
// registration boilerplate so the plugin is recognized on Linux.

struct _NativeNaturalSortPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(NativeNaturalSortPlugin, native_natural_sort_plugin, g_object_get_type())

static void native_natural_sort_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(native_natural_sort_plugin_parent_class)->dispose(object);
}

static void native_natural_sort_plugin_class_init(NativeNaturalSortPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = native_natural_sort_plugin_dispose;
}

static void native_natural_sort_plugin_init(NativeNaturalSortPlugin* self) {}

void native_natural_sort_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  // No MethodChannel registration needed — collation uses Dart FFI.
  g_type_class_ref(native_natural_sort_plugin_get_type());
}
