import 'package:aurenix/core/storage/storage_service.dart';

/// Remembers, across app launches, whether someone is signed in and whether
/// onboarding has already been through once. Splash reads it to decide where
/// the app opens.
class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  static const _signedInKey = 'signed_in';
  static const _onboardedKey = 'onboarding_seen';

  final _storage = StorageService.instance;

  bool get isSignedIn => _storage.getBool(_signedInKey);

  bool get hasOnboarded => _storage.getBool(_onboardedKey);

  /// Called once a sign in, sign up or verification goes through.
  Future<void> signIn() async {
    await _storage.setBool(_onboardedKey, value: true);
    await _storage.setBool(_signedInKey, value: true);
  }

  Future<void> signOut() => _storage.remove(_signedInKey);

  /// Onboarding is only shown on the very first run.
  Future<void> markOnboarded() => _storage.setBool(_onboardedKey, value: true);
}
