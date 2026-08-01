import Flutter
import FirebaseCore
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var screenshotChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if FirebaseApp.app() == nil {
      if let googleServicePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
         let firebaseOptions = FirebaseOptions(contentsOfFile: googleServicePath) {
        FirebaseApp.configure(options: firebaseOptions)
      } else {
        NSLog("[PGPChat] GoogleService-Info.plist not found. Firebase is disabled for this launch.")
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    screenshotChannel = FlutterMethodChannel(
      name: "com.pgpchat/screenshot",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenshotTaken),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc func screenshotTaken() {
    screenshotChannel?.invokeMethod("onScreenshotDetected", arguments: nil)
  }
}
