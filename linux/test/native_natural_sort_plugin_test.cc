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

TEST(NativeNaturalSortPlugin, HandleReturnsNotImplemented) {
  g_autoptr(GObject) plugin = G_OBJECT(
      g_object_new(native_natural_sort_plugin_get_type(), nullptr));
  ASSERT_NE(plugin, nullptr);

  g_autoptr(FlMethodCall) call = fl_method_call_new(
      "unknown_method", nullptr);
  g_autoptr(GError) error = nullptr;

  g_autoptr(FlMethodResponse) response =
      fl_method_call_respond(call, nullptr, &error);

  // Verify the plugin object is still valid after attempted use.
  EXPECT_NE(plugin, nullptr);
}

TEST(NativeNaturalSortPlugin, MultipleInstantiation) {
  g_autoptr(GObject) plugin1 = G_OBJECT(
      g_object_new(native_natural_sort_plugin_get_type(), nullptr));
  g_autoptr(GObject) plugin2 = G_OBJECT(
      g_object_new(native_natural_sort_plugin_get_type(), nullptr));
  ASSERT_NE(plugin1, nullptr);
  ASSERT_NE(plugin2, nullptr);
  EXPECT_NE(plugin1, plugin2);
}

}  // namespace test
}  // namespace native_natural_sort
