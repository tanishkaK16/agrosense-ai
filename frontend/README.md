# AgroSense AI — Farmer App (Flutter)

## Running locally

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Localization

ARB files live in `lib/l10n/`. Three locales: English (`app_en.arb`), Hindi (`app_hi.arb`), Marathi (`app_mr.arb`).

After editing ARB files, run `flutter gen-l10n` to regenerate `lib/generated/l10n/`.

## Farm photographs

Photo assets live in `assets/images/`. The project ships with placeholder files. Replace them with:

| Filename | Shot description |
|---|---|
| `hero_wheat_closeup.jpg` | Close-up of ripe wheat ears, warm golden hour light, shallow depth of field |
| `hero_field_wide.jpg` | Wide paddy or wheat field at golden hour, Maharashtra, warm tones |
| `hero_soil_hands.jpg` | Farmer's hands holding rich dark soil, morning light |
| `hero_canopy_green.jpg` | Green crop canopy from slightly above, fresh growth |
| `hero_field_sunrise.jpg` | Flat field with sunrise sky, dramatic warm horizon |

Recommended source: [Unsplash](https://unsplash.com) (license: Unsplash License, free for use).
Search queries: "wheat field golden hour", "India paddy field sunrise", "farmer hands soil", "crop canopy green".

## Environment

Copy `.env.example` to `.env`. Phase 0 does not read it.

## Folder structure

```
lib/
  main.dart
  app.dart
  core/
    theme/        design tokens
    l10n/         locale controller
    constants/    sizes, etc.
    routing/      go_router
    widgets/      shared UI components
  features/
    onboarding/   language_screen.dart
    shell/        main_shell.dart (floating nav)
    home/         home_screen.dart
    fields/       fields_screen.dart
    alerts/       alerts_screen.dart
  generated/l10n/ (generated — do not edit)
```

Android emulator may need a Google speech pack and a working mic.

