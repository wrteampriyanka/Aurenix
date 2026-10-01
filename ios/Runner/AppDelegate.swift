import AVKit
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AudioRoutePicker") {
      AudioRoutePicker.register(with: registrar)
    }
  }
}

/// Opens the system audio output picker (speaker, AirPods, Bluetooth), since
/// iOS doesn't let apps find or connect headphones themselves.
final class AudioRoutePicker: NSObject, FlutterPlugin {
  /// Kept in the window, invisible, so the picker it opens stays anchored.
  private var picker: AVRoutePickerView?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "aurenix/audio_route", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(AudioRoutePicker(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "showPicker" else { return result(FlutterMethodNotImplemented) }
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    guard let window else { return result(false) }
    let picker = self.picker ?? AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    picker.alpha = 0.01
    if picker.superview !== window { window.addSubview(picker) }
    self.picker = picker
    // The picker has no API to open it, so press its button.
    let button = picker.subviews.compactMap { $0 as? UIButton }.first
    button?.sendActions(for: .touchUpInside)
    result(button != nil)
  }
}
