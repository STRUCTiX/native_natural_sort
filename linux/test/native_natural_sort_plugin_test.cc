#include <flutter_linux/flutter_linux.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "include/native_natural_sort/native_natural_sort_plugin.h"

// Linux uses Dart FFI (collation_ffi_linux.dart) for collation — the native
// plugin class is minimal. These tests verify the plugin can be instantiated
// and registered without errors.

namespace native_natural_sort {
namespace test {

TEST(NativeNaturalSortPlugin, GetType) {
  GType type = native_natural_sort_plugin_get_type();
  ASSERT_NE(type, G_TYPE_INVALID);
  ASSERT_NE(type, G_TYPE_NONE);
}

TEST(NativeNaturalSortPlugin, Instantiate) {
  g_autoptr(GObject) plugin = G_OBJECT(
      g_object_new(native_natural_sort_plugin_get_type(), nullptr));
  ASSERT_NE(plugin, nullptr);
}

}  // namespace test
}  // namespace native_natural_sort
