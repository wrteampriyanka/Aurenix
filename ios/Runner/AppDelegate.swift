import AVKit
import CoreImage
import Flutter
import ReplayKit
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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ScreenShare") {
      ScreenShare.register(with: registrar)
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

/// Screen sharing in live talk: ReplayKit records the screen and the latest
/// frame goes out as a JPEG when asked. In-app capture only sees this app;
/// seeing other apps needs a Broadcast Upload Extension, which isn't set up.
final class ScreenShare: NSObject, FlutterPlugin, RPScreenRecorderDelegate {
  private let channel: FlutterMethodChannel
  private let lock = NSLock()
  private var latest: CVPixelBuffer?
  private let context = CIContext()
  private let encoder = DispatchQueue(label: "aurenix.screen_share")

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "aurenix/screen_share", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(ScreenShare(channel: channel), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let recorder = RPScreenRecorder.shared()
    switch call.method {
    case "isSharing":
      result(recorder.isRecording)
    case "start":
      if recorder.isRecording { return result(true) }
      guard recorder.isAvailable else {
        return result(FlutterError(code: "unavailable", message: "Screen recording is unavailable", details: nil))
      }
      recorder.delegate = self
      // The microphone belongs to speech recognition.
      recorder.isMicrophoneEnabled = false
      recorder.isCameraEnabled = false
      recorder.startCapture(
        handler: { [weak self] sample, type, _ in
          guard type == .video, let self, let buffer = CMSampleBufferGetImageBuffer(sample) else {
            return
          }
          self.lock.lock()
          self.latest = buffer
          self.lock.unlock()
        },
        completionHandler: { error in
          DispatchQueue.main.async {
            if let error {
              result(FlutterError(code: "failed", message: error.localizedDescription, details: nil))
            } else {
              result(true)
            }
          }
        })
    case "capture":
      let args = call.arguments as? [String: Any]
      let maxSide = CGFloat(args?["maxSide"] as? Int ?? 1280)
      let quality = CGFloat(args?["quality"] as? Int ?? 70) / 100
      encoder.async { [weak self] in
        let data = self?.jpeg(maxSide: maxSide, quality: quality)
        DispatchQueue.main.async { result(data.map { FlutterStandardTypedData(bytes: $0) }) }
      }
    case "stop":
      clearFrame()
      guard recorder.isRecording else { return result(nil) }
      recorder.stopCapture { _ in DispatchQueue.main.async { result(nil) } }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func clearFrame() {
    lock.lock()
    latest = nil
    lock.unlock()
  }

  /// The latest frame, scaled to fit [maxSide], or nil before the first one.
  private func jpeg(maxSide: CGFloat, quality: CGFloat) -> Data? {
    lock.lock()
    let buffer = latest
    lock.unlock()
    guard let buffer else { return nil }
    var image = CIImage(cvPixelBuffer: buffer)
    let scale = maxSide / max(image.extent.width, image.extent.height)
    if scale < 1 { image = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale)) }
    guard let cgImage = context.createCGImage(image, from: image.extent) else { return nil }
    return UIImage(cgImage: cgImage).jpegData(compressionQuality: quality)
  }

  /// The system ended the capture, e.g. for a phone call.
  func screenRecorder(
    _ screenRecorder: RPScreenRecorder,
    didStopRecordingWith previewViewController: RPPreviewViewController?,
    error: Error?
  ) {
    clearFrame()
    DispatchQueue.main.async { self.channel.invokeMethod("stopped", arguments: nil) }
  }
}
