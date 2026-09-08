# AgroSense AI — Farmer App (Flutter)

This repository contains the farmer mobile client for AgroSense AI. It is designed specifically for rural connectivity, high sunlight readability, and voice-assisted interaction for digitally inexperienced farmers.

Backend services (Django REST API, satellite processing pipelines, and SMS gateways) live in `../backend`.

---

## Prerequisites

- Flutter SDK (3.16 or newer recommended)
- Android SDK / Android Studio or physical Android device

---

## How to Run

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate localization files:
   ```bash
   flutter gen-l10n
   ```

3. Run in fallback/offline mode (default):
   ```bash
   flutter run --dart-define=API_USE_LIVE=false
   ```

4. Run against a live backend server:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api --dart-define=API_USE_LIVE=true
   ```
   *(Note: Use `10.0.2.2` when connecting to localhost from the Android emulator, or your local machine IP on a physical device).*

---

## Languages

The app is fully localized in three languages:
- English (`en`)
- Hindi (`hi`)
- Marathi (`mr`)

Farmers can change their preferred language directly from the welcome screen, the top bar of the phone/OTP sign-in screens, or the Account tab.

---

## Authentication & Demo OTP

- Enter any valid 10-digit Indian mobile number (e.g. `9876543210`).
- Use the demo verification code: **`1234`**.
- In fallback mode (`API_USE_LIVE=false`), verification succeeds locally and stores the session securely on-device.

---

## Configuration & Live Switch (`API_USE_LIVE`)

The client supports dual operation via repository abstraction:
- **`API_USE_LIVE=false` (default)**: Operates completely offline with built-in realistic mock repositories. All field registration, status checking, and alerts work immediately without requiring any backend services.
- **`API_USE_LIVE=true`**: Connects to the Django backend specified by `API_BASE_URL`. If the backend is unreachable or returns a server error, the client gracefully falls back to cached data.

---

## Offline Continuity & Airplane-Mode Cache

- All fetched or created fields, health status meters, and actionable alerts are persisted to local device storage using encrypted key-value preferences.
- Once launched, the app remains fully functional in airplane mode with no internet connectivity.
- Farmers can view their fields, examine previous health scores, and read recommendations even in remote rural areas with zero signal.

---

## Text Size & Sunlight Readability

- A farmer-visible text size selector is accessible directly from the top bar of the Home screen and the Account tab.
- Options:
  - **Small** (0.9x scale)
  - **Default** (1.0x scale)
  - **Large** (1.25x scale)
- Clamped with the system font scaling factor to maintain layout stability (maximum scale clamped at 1.4x).
- High-contrast color tokens ensure readability under intense sunlight (5.3:1 contrast ratio against warm cream backgrounds).

---

## Voice Assistance & Emulator Limitations

- **Listen (Speaker)**: Reads the current screen aloud using Text-to-Speech (TTS) in the selected language.
- **Talk (Mic)**: Accepts spoken commands in English, Hindi, or Marathi to navigate or inspect field status.
- **Android Emulator Limitations**:
  - TTS and speech recognition depend on Android system speech engines.
  - The standard Android emulator image may not have the Google Speech Recognition pack or Hindi/Marathi TTS voices preinstalled.
  - On emulators lacking speech engines, the app falls back gracefully without crashing.
  - For full voice testing, test on a physical Android device with Google Text-to-Speech enabled and offline speech packs downloaded.

---

## Project Structure

```
frontend/
  lib/
    main.dart
    app.dart
    core/
      api/          api client, network exceptions, config
      constants/    spacing and asset definitions
      l10n/         locale controller and ARB files
      routing/      go_router setup and route definitions
      storage/      shared preferences wrapper and offline cache
      theme/        color tokens, typography, text scale controller
      voice/        text-to-speech and speech-to-text service
      widgets/      reusable farmer-friendly UI components
    features/
      account/      profile, language switch, text size, and logout
      alerts/       actionable alert cards and details
      auth/         phone login, demo OTP, and initial profile
      fields/       field list, pin-drop mapping, and health detail
      home/         greeting, weather strip, and quick overview
      onboarding/   language selection and introductory tour
      shell/        scaffold with high-contrast floating pill navigation
      sms/          SMS alert explainer for feature phones
  store/            Play Store listing texts (EN, HI, MR) and asset specs
  test/             unit, widget, and repository tests
```
