import 'dart:async';

import 'package:get/get.dart';

import 'package:aurenix/core/storage/storage_service.dart';

/// The free plan's message allowance, like ChatGPT's or Gemini's: a set
/// number of messages per window. The window opens with the first message
/// sent after the last one closed, and once it is used up the chat is shut
/// until the window runs out. Kept on the device, so restarting the app
/// does not hand out a fresh allowance.
class ChatQuotaService {
  ChatQuotaService._();

  static final ChatQuotaService instance = ChatQuotaService._();

  /// Messages the free plan gets per [window].
  static const freeMessages = 10;

  /// How long the allowance lasts, counted from the first message.
  static const window = Duration(hours: 12);

  static const _countKey = 'chat_quota_count';
  static const _windowStartKey = 'chat_quota_window_start';

  /// Messages sent in the current window.
  final used = 0.obs;

  /// When the current window closes and the allowance comes back; null
  /// while no window is open.
  final resetsAt = Rxn<DateTime>();

  /// Set once a paid plan is active: the allowance no longer applies.
  final isUnlimited = false.obs;

  Timer? _reset;

  /// Whether the allowance is used up and the chat is shut for now.
  bool get isLimited => !isUnlimited.value && used.value >= freeMessages;

  /// Messages still left in the current window.
  int get remaining => (freeMessages - used.value).clamp(0, freeMessages);

  /// Reads the saved window back. Call once after [StorageService.init].
  void init() {
    final storage = StorageService.instance;
    final start = storage.getInt(_windowStartKey);
    if (start == null) return;
    final end = DateTime.fromMillisecondsSinceEpoch(start).add(window);
    if (!end.isAfter(DateTime.now())) {
      _clear();
      return;
    }
    used.value = storage.getInt(_countKey) ?? 0;
    resetsAt.value = end;
    _scheduleReset(end);
  }

  /// Counts one message against the allowance, opening a window if none is.
  void recordMessage() {
    if (isUnlimited.value) return;
    final storage = StorageService.instance;
    if (resetsAt.value == null) {
      final now = DateTime.now();
      final end = now.add(window);
      resetsAt.value = end;
      storage.setInt(_windowStartKey, now.millisecondsSinceEpoch);
      _scheduleReset(end);
    }
    used.value++;
    storage.setInt(_countKey, used.value);
  }

  /// A paid plan lifts the allowance.
  void activatePlan() {
    isUnlimited.value = true;
    _clear();
  }

  /// Checks the clock again, for when the reset timer could not fire —
  /// the app was paused in the background past [resetsAt].
  void refresh() {
    final end = resetsAt.value;
    if (end != null && !end.isAfter(DateTime.now())) _clear();
  }

  void _scheduleReset(DateTime end) {
    _reset?.cancel();
    _reset = Timer(end.difference(DateTime.now()), _clear);
  }

  void _clear() {
    _reset?.cancel();
    _reset = null;
    used.value = 0;
    resetsAt.value = null;
    StorageService.instance
      ..remove(_countKey)
      ..remove(_windowStartKey);
  }
}
