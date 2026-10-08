import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aurenix/core/services/voice_service.dart';
import 'package:aurenix/commons/widgets/app_snackbar.dart';
import 'package:aurenix/core/constants/app_strings.dart';

/// Voice Preferences: swipe through the voices, each one introduces itself
/// as it comes into view, and Save keeps the one on screen.
class VoiceSettingsController extends GetxController {
  final voices = VoiceService.voices;

  final _voice = VoiceService.instance;

  late final index = voices.indexOf(VoiceService.instance.selected.value).obs;
  late final pageController = PageController(initialPage: index.value);

  /// True while the voice on screen is talking.
  final isSpeaking = false.obs;

  /// Bumped to drop a preview that was cut off by a swipe.
  var _run = 0;
  var _closed = false;

  AssistantVoice get current => voices[index.value];

  @override
  void onReady() {
    super.onReady();
    _preview();
  }

  void onPageChanged(int value) {
    index.value = value;
    _preview();
  }

  void onDot(int value) => pageController.animateToPage(
    value,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );

  /// Tapping the orb plays the voice again, or stops it.
  void onOrb() => isSpeaking.value ? _stop() : _preview();

  Future<void> _preview() async {
    final run = ++_run;
    await _voice.stop();
    if (_closed || run != _run) return;
    final voice = current;
    isSpeaking.value = true;
    try {
      await _voice.speak(
        AppStrings.voiceSample.trParams({
          'name': voice.name,
          'tagline': voice.taglineKey.tr,
        }),
        voice: voice,
      );
    } catch (_) {
      // The names and orb still let them choose.
    }
    if (run == _run) isSpeaking.value = false;
  }

  Future<void> _stop() async {
    _run++;
    isSpeaking.value = false;
    await _voice.stop();
  }

  Future<void> onSave() async {
    await _stop();
    await VoiceService.instance.select(current);
    Get.back(result: current);
    AppSnackbar.show(
      AppStrings.voiceSaved.trParams({'name': current.name}),
      duration: const Duration(seconds: 2),
    );
  }

  /// Leaves without changing the saved voice.
  void onDismiss() => Get.back();

  @override
  void onClose() {
    _closed = true;
    _stop();
    pageController.dispose();
    super.onClose();
  }
}
