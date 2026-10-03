# Aurenix

A Flutter AI assistant app — chat with text/voice/vision, live talk, projects and
collaboration, presets, memories, and a settings/upgrade flow — targeting Android,
iOS, and Web (a Windows runner is also checked in).

## Tech stack

- **Flutter 3.47.x** / Dart SDK `^3.13.4`
- **GetX** (`get`) for routing, bindings, controllers and state
- **Localization** — custom `AppTranslations` (GetX `Translations`) backed by
  `assets/translations/*.json`: English, Hindi and Arabic (incl. RTL)
- **Voice** — `speech_to_text` (STT), `flutter_tts` (TTS), `audio_session`
- **Media / input** — `camera`, `image_picker`, `file_picker`
- **UI** — `phosphoricons_flutter`, `flutter_svg`, `flutter_markdown_plus`,
  Space Grotesk as the app font
- **Local storage** — `shared_preferences` via `StorageService`
- **Misc** — `share_plus`, `url_launcher`, `http`

> The chat surface currently runs on `DemoChatService` (bundled demo data), so the
> app is fully navigable without a backend.

## Prerequisites

- Flutter SDK 3.47+ (channel `stable`) — verify with `flutter --version`
- Dart SDK `^3.13.4` (bundled with the above Flutter version)
- Xcode with CocoaPods installed (for iOS builds)
- Android Studio / Android SDK (for Android builds)
- A connected device, simulator/emulator, or Chrome for web

## Setup

Clone the repository and install dependencies:

```bash
flutter pub get
```

iOS only — install CocoaPods dependencies:

```bash
cd ios && pod install && cd ..
```

### Environment

`.env` and `env.json` (both git-ignored) hold the model credentials used once the
live AI backend is wired in:

```json
{
  "GEMINI_API_KEY": "<your key>",
  "GEMINI_MODEL": "<model id>"
}
```

Nothing in `lib/` reads them yet, so the app runs as-is without them.

### Permissions

Live talk, voice input, camera and screen share need runtime permissions
(microphone, speech recognition, camera) declared in
`android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.

## Running the app

```bash
# List available devices
flutter devices

# Run on a connected device/simulator/emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome
```

## Building

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (requires macOS + Xcode)
flutter build ios

# Web
flutter build web
```

## Other useful commands

```bash
# Static analysis
flutter analyze

# Run tests
flutter test
```

## Project structure

The codebase keeps app-wide foundation in `core/` and groups everything else by
feature under `features/`, each feature owning its own binding, controller and
private widgets:

```
lib/
├── main.dart
│
├── core/                           # app-wide foundation, no screens
│   ├── constants/
│   │   ├── app_assets.dart         # every asset path
│   │   └── app_constants.dart      # app name and other global values
│   ├── localization/
│   │   └── app_translations.dart   # GetX Translations, loads assets/translations
│   ├── routes/
│   │   ├── app_routes.dart         # route NAMES for the whole app
│   │   └── app_pages.dart          # GetPage table + bindings
│   ├── services/
│   │   ├── demo_chat_service.dart  # demo chat/vision/image replies
│   │   ├── language_service.dart   # supported locales + current locale
│   │   ├── voice_service.dart      # STT + TTS
│   │   └── screen_share_service.dart
│   ├── storage/
│   │   └── storage_service.dart    # shared_preferences wrapper
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart          # AppTheme.light
│
├── features/
│   ├── widgets/                    # shared widgets across features
│   │   ├── app_button.dart, app_text_field.dart, custom_text.dart,
│   │   ├── app_background.dart, app_top_bar.dart, app_snackbar.dart, …
│   │   └── bottom_sheets/          # shared sheets (language, create project, …)
│   │
│   └── <feature_name>/             # e.g. home, projects, presets, profile
│       ├── <feature>_screen.dart
│       ├── bindings/               # GetX binding for the route
│       ├── controllers/            # GetX controllers for this feature
│       ├── widgets/                # widgets private to THIS feature
│       └── models/                 # this feature's data classes (when needed)
│
└── utils/
    ├── validators.dart
    └── elapsed_time_mixin.dart
assets/
├── fonts/                          # Space Grotesk family
├── images/                         # svg + png, grouped per screen
│   ├── app_icon/, log_in_icon/, home_screen_icon/,
│   └── platfom_logo/, presets/, pyment/
└── translations/
    ├── en_US.json                  # translation CONTENT
    ├── hi_IN.json
    └── ar_SA.json
```

### Screens

Routes are declared in `core/routes/app_routes.dart` and wired in `app_pages.dart`:

- **Onboarding & auth** — splash, onboarding, login, register, otp, reset password
- **Assistant** — home (chat + sidebar), live talk, archive chats, memories
- **Work** — projects, project detail, collaboration, presets, preset detail,
  connected apps
- **Money** — budget, transactions, categories, savings, checkout, upgrade
- **Settings** — profile, edit profile, customize AI, voice settings, data control
- **Legal** — about us, privacy policy
