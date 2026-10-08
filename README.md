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
- **Misc** — `share_plus`, `url_launcher`

> The chat surface currently runs on `DemoChatService` (bundled demo data), so the
> app is fully navigable without a backend.

## Prerequisites

- Flutter SDK 3.47+ (channel `stable`) — verify with `flutter --version`
- Dart SDK `^3.13.0` (bundled with the above Flutter version)
- Xcode with CocoaPods installed (for iOS builds)
- Android Studio / Android SDK (for Android builds)
- A connected device, simulator/emulator, or Chrome for web

**Keep the checkout out of iCloud Drive.** iCloud adds extended attributes
that `codesign` rejects, and `xattr -cr` does not clear `com.apple.provenance`,
so an iOS build fails with *"resource fork, Finder information, or similar
detritus not allowed"*. A path like `~/dev/aurenix` is fine; `~/Desktop` and
`~/Documents` are synced by default on many Macs.

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
# Android App Bundle — what Play Store wants. Play delivers only the ABI a
# given device needs, so the ~20 MB of x86_64 native libraries in the bundle
# cost real users nothing.
flutter build appbundle

# Android APKs for direct distribution — always split per ABI. A single fat
# APK is ~58 MB because it carries all three ABIs; arm64 alone is ~22 MB.
flutter build apk --release --split-per-abi

# iOS (requires macOS + Xcode; see the iCloud note in Prerequisites)
cd ios && pod install && cd ..
flutter build ios --release

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

Tests cover the pure logic only: `Validators`, `ChatQuotaService` (window
arithmetic and what survives a restart), `VoiceService` text splitting, and
translation-file parity. There are no widget tests yet.

## Known platform risks

Things that build today but are on a clock. None is fixable in this repo.

| What | Impact | Where it stands |
|---|---|---|
| `flutter_tts` applies the legacy Kotlin Gradle Plugin | AGP 9 removes KGP support, so the Android build will fail | Upstream [PR #656](https://github.com/dlutton/flutter_tts/pull/656) is open and unmerged |
| `flutter_tts` has not adopted Swift Package Manager | A future Flutter turns today's warning into an error | Upstream [PR #657](https://github.com/dlutton/flutter_tts/pull/657) is open and unmerged |
| `flutter_tts` web fails the Wasm dry run | `flutter build web --wasm` is not possible; the JS target is fine | Same package |
| `phosphoricons_flutter` declares six font families | ~1.6 MB of Thin, Light and Duotone ship unused: the icon tree-shaker only shrinks families the code references | Needs a fork declaring the three we use (Regular, Fill, Bold), pulled in with `dependency_overrides` |

TTS is load-bearing for live talk and read-aloud, so the `flutter_tts` items
are worth watching rather than discovering at the next Flutter upgrade.

## Outstanding backend work

`analysis_options.yaml` sets `todo: ignore`, so the 47 `// TODO` comments
in `lib/` stay out of the IDE's Problems panel. They are not forgotten — they
mark where the API will plug in, and they sit in three predictable places:

| Where | What is left |
|---|---|
| `features/<x>/dummy/` | Delete the file once the API serves that data. |
| `features/<x>/repositories/` | Swap the body for the real call; controllers do not change. |
| `features/<x>/controllers/` | Actions with no endpoint yet (auth, payment, sync). |

List them with:

```bash
grep -rn "// TODO" lib/
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
│   ├── bindings/
│   │   └── initial_binding.dart    # what is registered before the first route
│   ├── constants/
│   │   ├── app_assets.dart         # every asset path
│   │   ├── app_constants.dart      # app name and other global values
│   │   └── app_strings.dart        # every translation KEY, as a constant
│   ├── localization/
│   │   └── app_translations.dart   # GetX Translations, loads assets/translations
│   ├── routes/
│   │   ├── app_routes.dart         # route NAMES for the whole app
│   │   └── app_pages.dart          # GetPage table + bindings
│   ├── services/
│   │   ├── chat_quota_service.dart # the free plan's message allowance
│   │   ├── demo_chat_service.dart  # demo chat/vision/image replies
│   │   ├── language_service.dart   # supported locales + current locale
│   │   ├── screen_share_service.dart
│   │   ├── session_service.dart    # signed in / onboarded flags
│   │   └── voice_service.dart      # the one TTS engine, and the voices
│   ├── storage/
│   │   └── storage_service.dart    # shared_preferences wrapper
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart        # AppSpacing, AppRadius
│       ├── app_text_styles.dart    # AppFontSize, AppFontWeight
│       └── app_theme.dart          # AppTheme.dark (dark-only)
│
├── commons/
│   └── widgets/                    # shared widgets across features
│       ├── app_button.dart, app_text_field.dart, app_text.dart,
│       ├── app_background.dart, app_top_bar.dart, app_snackbar.dart, …
│       └── bottom_sheets/          # shared sheets (language, create project, …)
│
├── features/
│   └── <feature_name>/             # e.g. home, projects, presets, profile
│       ├── <feature>_screen.dart
│       ├── bindings/               # GetX binding for the route
│       ├── controllers/            # GetX controllers for this feature
│       ├── widgets/                # widgets private to THIS feature
│       ├── models/                 # this feature's data classes
│       ├── repositories/           # where its data comes from
│       └── dummy/                  # stand-in data until the API lands
│
└── utils/
    ├── validators.dart
    └── elapsed_time_mixin.dart
assets/
├── fonts/                          # Space Grotesk family
├── images/                         # svg + png, grouped per screen
│   ├── app_icon/, log_in_icon/, home_screen_icon/,
│   └── platform_logo/, presets/, payment/
└── translations/
    ├── en_US.json                  # translation CONTENT
    ├── hi_IN.json
    └── ar_SA.json
test/
├── core/
│   ├── localization/               # translation file parity
│   └── services/                   # ChatQuotaService, VoiceService
└── utils/                          # Validators
```

### Screens

Routes are declared in `core/routes/app_routes.dart` and wired in `app_pages.dart`:

- **Onboarding & auth** — splash, onboarding, login, register, otp, reset password
- **Assistant** — home (chat + sidebar), live talk, archive chats, memories
- **Work** — projects, project detail, collaboration, presets, preset detail,
  connected apps
- **Billing** — checkout, upgrade
- **Settings** — profile, edit profile, customize AI, voice settings, data control
- **Legal** — about us, privacy policy
