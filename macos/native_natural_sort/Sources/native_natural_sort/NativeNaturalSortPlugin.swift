import Cocoa
import FlutterMacOS

/// Native natural sort plugin for macOS.
///
/// Uses [localizedStandardCompare] for locale-aware string collation
/// via the Pigeon-generated CollationHostApi interface.
public class NativeNaturalSortPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    CollationMacOSHostApiSetup.setUp(
      binaryMessenger: registrar.messenger,
      api: CollationPlugin())
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }
}
