import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';

/// Why the code is being verified, which decides where Continue leads.
enum OtpPurpose { register, resetPassword }

/// Route arguments for the OTP screen.
class OtpArgs {
  const OtpArgs({required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;
}

class OtpController extends GetxController {
  static const codeLength = 4;
  static const _resendDelay = Duration(minutes: 2);

  final codeController = TextEditingController();
  final codeFocusNode = FocusNode();

  final OtpArgs? _args = Get.arguments as OtpArgs?;

  /// Email the code was sent to.
  String? get email => _args?.email;

  /// Seconds left before a new code can be requested.
  final resendSeconds = 0.obs;
  Timer? _resendTimer;

  late final termsRecognizer = TapGestureRecognizer()..onTap = onTermsTap;
  late final privacyRecognizer = TapGestureRecognizer()..onTap = onPrivacyTap;
  late final resendRecognizer = TapGestureRecognizer()..onTap = onResendCode;

  bool get canResend => resendSeconds.value == 0;

  /// Countdown as `mm:ss`.
  String get resendCountdown {
    final s = resendSeconds.value;
    final minutes = (s ~/ 60).toString().padLeft(2, '0');
    final seconds = (s % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = _resendDelay.inSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (--resendSeconds.value <= 0) timer.cancel();
    });
  }

  void onContinue() {
    if (codeController.text.length < codeLength) {
      codeFocusNode.requestFocus();
      return;
    }
    // TODO: verify the code for [email].
    switch (_args?.purpose) {
      case OtpPurpose.resetPassword:
        Get.toNamed(AppRoutes.resetPassword, arguments: email);
      case OtpPurpose.register || null:
        // Account is verified: clear the auth screens so back can't return.
        Get.offAllNamed(AppRoutes.home);
    }
  }

  void onResendCode() {
    if (!canResend) return;
    codeController.clear();
    _startResendTimer();
    // TODO: request a new verification code for [email].
  }

  // TODO: wire up once the legal pages exist.
  void onTermsTap() {}
  void onPrivacyTap() {}

  @override
  void onClose() {
    _resendTimer?.cancel();
    codeController.dispose();
    codeFocusNode.dispose();
    termsRecognizer.dispose();
    privacyRecognizer.dispose();
    resendRecognizer.dispose();
    super.onClose();
  }
}
