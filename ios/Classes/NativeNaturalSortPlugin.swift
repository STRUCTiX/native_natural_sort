import Flutter
import UIKit

/// Native natural sort plugin for iOS.
///
/// Uses [localizedStandardCompare] for locale-aware string collation
/// via the Pigeon-generated CollationHostApi interface.
public class NativeNaturalSortPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    CollationHostApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: CollationPlugin())
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }
}
