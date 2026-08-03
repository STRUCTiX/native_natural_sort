package io.github.friesi23.native_natural_sort

import io.flutter.embedding.engine.plugins.FlutterPlugin

/// Native natural sort plugin for Android.
///
/// Uses [android.icu.text.Collator] for locale-aware, numeric-aware string
/// collation via the Pigeon-generated [CollationHostApi] interface.
class NativeNaturalSortPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        CollationAndroidHostApi.setUp(binding.binaryMessenger, CollationPlugin())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        CollationAndroidHostApi.setUp(binding.binaryMessenger, null)
    }
}
