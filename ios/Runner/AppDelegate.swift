import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as? FlutterViewController
    let runtimeChannel = FlutterMethodChannel(
      name: "bodybuddies/runtime",
      binaryMessenger: controller!.binaryMessenger
    )

    runtimeChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "isTestFlight":
        result(Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt")
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
