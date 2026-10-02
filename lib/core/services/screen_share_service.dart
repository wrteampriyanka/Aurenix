import 'package:flutter/services.dart';

/// Screen sharing for live talk, backed by MediaProjection on Android and
/// ReplayKit on iOS (see `ScreenShare` in each platform folder).
///
/// Starting asks the user for consent. While sharing, [capture] returns a
/// screenshot: on Android of whatever is on screen, including other apps;
/// on iOS of this app only, as other apps need a broadcast extension.
class ScreenShareService {
  ScreenShareService._() {
    _channel.setMethodCallHandler(_onCall);
  }

  static final instance = ScreenShareService._();

  static const _channel = MethodChannel('aurenix/screen_share');

  /// Called when the share ends outside the app, e.g. from the status bar.
  void Function()? onStopped;

  /// Asks for consent and starts capturing. False when the user declined,
  /// null when the platform can't share. The strings fill the Android
  /// notification that the system shows while sharing.
  Future<bool?> start({
    required String channelName,
    required String title,
    required String text,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('start', {
        'channel_name': channelName,
        'title': title,
        'text': text,
      });
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// A JPEG of the screen, or null when not sharing or no frame has
  /// arrived yet.
  Future<Uint8List?> capture({int maxSide = 1280, int quality = 70}) async {
    try {
      return await _channel.invokeMethod<Uint8List>('capture', {
        'maxSide': maxSide,
        'quality': quality,
      });
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // Nothing to stop.
    } on MissingPluginException {
      // Not supported here.
    }
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method == 'stopped') onStopped?.call();
  }
}
