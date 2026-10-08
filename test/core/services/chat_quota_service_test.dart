import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aurenix/core/services/chat_quota_service.dart';
import 'package:aurenix/core/storage/storage_service.dart';

/// [ChatQuotaService] is a singleton, so each test puts it back to a known
/// state rather than building a fresh one.
Future<void> _reset({Map<String, Object> stored = const {}}) async {
  SharedPreferences.setMockInitialValues(stored);
  await StorageService.instance.init();
  final quota = ChatQuotaService.instance;
  quota.isUnlimited.value = false;
  quota.used.value = 0;
  quota.resetsAt.value = null;
}

const _countKey = 'chat_quota_count';
const _startKey = 'chat_quota_window_start';

int _msAgo(Duration d) => DateTime.now().subtract(d).millisecondsSinceEpoch;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final quota = ChatQuotaService.instance;

  group('a fresh install', () {
    setUp(() async => _reset());

    test('starts with the whole allowance and no window', () async {
      await quota.init();
      expect(quota.used.value, 0);
      expect(quota.remaining, ChatQuotaService.freeMessages);
      expect(quota.resetsAt.value, isNull);
      expect(quota.isLimited, isFalse);
    });

    test('the first message opens the window', () async {
      await quota.init();
      quota.recordMessage();
      expect(quota.used.value, 1);
      expect(quota.resetsAt.value, isNotNull);
      expect(
        quota.resetsAt.value!.difference(DateTime.now()).inMinutes,
        closeTo(ChatQuotaService.window.inMinutes, 1),
      );
    });

    test('later messages do not move the window', () async {
      await quota.init();
      quota.recordMessage();
      final end = quota.resetsAt.value;
      quota.recordMessage();
      quota.recordMessage();
      expect(quota.used.value, 3);
      expect(quota.resetsAt.value, end);
    });

    test('the allowance runs out at exactly freeMessages', () async {
      await quota.init();
      for (var i = 0; i < ChatQuotaService.freeMessages - 1; i++) {
        quota.recordMessage();
      }
      expect(quota.isLimited, isFalse, reason: 'one still left');
      expect(quota.remaining, 1);
      quota.recordMessage();
      expect(quota.isLimited, isTrue);
      expect(quota.remaining, 0);
    });

    test('remaining never goes negative', () async {
      await quota.init();
      for (var i = 0; i < ChatQuotaService.freeMessages + 5; i++) {
        quota.recordMessage();
      }
      expect(quota.remaining, 0);
    });
  });

  group('across a restart', () {
    test('a window still open is read back with its count', () async {
      await _reset(
        stored: {_startKey: _msAgo(const Duration(hours: 2)), _countKey: 4},
      );
      await quota.init();
      expect(quota.used.value, 4);
      expect(quota.resetsAt.value, isNotNull);
      expect(
        quota.resetsAt.value!.difference(DateTime.now()).inMinutes,
        closeTo(ChatQuotaService.window.inMinutes - 120, 1),
      );
    });

    test('a used-up window is still used up', () async {
      await _reset(
        stored: {
          _startKey: _msAgo(const Duration(hours: 1)),
          _countKey: ChatQuotaService.freeMessages,
        },
      );
      await quota.init();
      expect(quota.isLimited, isTrue);
    });

    test('a window that ran out while the app was closed is cleared', () async {
      await _reset(
        stored: {
          _startKey: _msAgo(
            ChatQuotaService.window + const Duration(minutes: 1),
          ),
          _countKey: ChatQuotaService.freeMessages,
        },
      );
      await quota.init();
      expect(quota.used.value, 0);
      expect(quota.resetsAt.value, isNull);
      expect(quota.isLimited, isFalse);
    });

    test('a window ending exactly now is treated as over', () async {
      await _reset(
        stored: {_startKey: _msAgo(ChatQuotaService.window), _countKey: 3},
      );
      await quota.init();
      expect(quota.resetsAt.value, isNull);
      expect(quota.used.value, 0);
    });

    test('a stored count with no window start is ignored', () async {
      await _reset(stored: {_countKey: 7});
      await quota.init();
      expect(quota.used.value, 0);
      expect(quota.resetsAt.value, isNull);
    });
  });

  group('refresh', () {
    test('clears a window whose time has passed', () async {
      await _reset();
      await quota.init();
      quota.recordMessage();
      // Pretend the app was in the background past the end of the window.
      quota.resetsAt.value = DateTime.now().subtract(
        const Duration(seconds: 1),
      );
      quota.refresh();
      expect(quota.used.value, 0);
      expect(quota.resetsAt.value, isNull);
    });

    test('leaves a window that is still open alone', () async {
      await _reset();
      await quota.init();
      quota.recordMessage();
      final end = quota.resetsAt.value;
      quota.refresh();
      expect(quota.used.value, 1);
      expect(quota.resetsAt.value, end);
    });
  });

  group('a paid plan', () {
    test('lifts the limit and clears the window', () async {
      await _reset();
      await quota.init();
      for (var i = 0; i < ChatQuotaService.freeMessages; i++) {
        quota.recordMessage();
      }
      expect(quota.isLimited, isTrue);
      quota.activatePlan();
      expect(quota.isLimited, isFalse);
      expect(quota.used.value, 0);
      expect(quota.resetsAt.value, isNull);
    });

    test('messages are no longer counted', () async {
      await _reset();
      await quota.init();
      quota.activatePlan();
      quota.recordMessage();
      quota.recordMessage();
      expect(quota.used.value, 0);
      expect(quota.resetsAt.value, isNull);
    });
  });
}
