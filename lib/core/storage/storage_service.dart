import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around local persistence. Call [init] once before [runApp].
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const voiceKey = 'voice_id';
  static const languageKey = 'language_code';

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Settings then last for this run only.
    }
  }

  String? getString(String key) => _prefs?.getString(key);

  Future<void> setString(String key, String value) async =>
      _prefs?.setString(key, value);

  bool getBool(String key) => _prefs?.getBool(key) ?? false;

  Future<void> setBool(String key, {required bool value}) async =>
      _prefs?.setBool(key, value);

  Future<void> remove(String key) async => _prefs?.remove(key);
}
