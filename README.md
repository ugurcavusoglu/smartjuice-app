# SmartJuice

A Flutter mobile application for a smart juice maker device. Built as a CENG318 course project.

## Features

- **Home Screen** — Animated juice glass that fills as you add ingredients. Physics-based fruit falling animation with wall and floor collisions, and inter-fruit collision detection.
- **Ingredient Picker** — Search and select from 18 fruits with emoji icons. Adjust serving count before confirming.
- **Vitamin Tracker** — Real-time vitamin bars (A, B, C, E, K) that update based on selected fruits.
- **Recipe Library** — Browse Favourites, Last Recipes, and Suggestions. Tap any recipe to pre-fill ingredients and confirm with one tap.
- **Bluetooth Status** — 5-state device status indicator: idle, in use, ready, estimating, juice ready.
- **Juice Making Flow** — Confirm ingredients → estimated time shown → glass fills → "Fruit juice is ready!" notification.
- **Dark Mode** — Full dark/light theme toggle, persisted across sessions.
- **Settings** — Silent mode, ml/oz unit toggle, editable username, Help popup, FAQ accordion.
- **Profile Page** — Accessible from the home screen top-right icon.
- **Auth Flow** — Splash → Login → Sign Up → QR scan → Main app.

## Tech Stack

| | |
|---|---|
| Framework | Flutter 3.27.2 |
| State Management | Provider |
| Navigation | go_router |
| Persistence | shared_preferences |
| Animation | AnimationController, Ticker (custom physics) |
| UI | CustomPaint, BackdropFilter, PageView |

## Project Structure

```
lib/
├── main.dart
├── app.dart                        # GoRouter routes
├── theme/
│   └── app_theme.dart              # Color palette, light/dark themes
├── models/
│   ├── ingredient.dart
│   └── recipe.dart
├── data/
│   └── static_recipes.dart         # 12 hardcoded recipes
├── providers/
│   ├── theme_provider.dart
│   ├── recipe_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── splash/
│   ├── auth/                       # login, signup, qr
│   ├── home/                       # main screen + physics animation
│   ├── recipes/                    # favourites / last / suggestions
│   └── settings/
└── widgets/
    └── juice_glass.dart            # CustomPaint glass widget
```

## Getting Started

**Requirements:** Flutter SDK 3.27+, Android SDK, Java 21

```bash
# 1. Repoyu klonla
git clone https://github.com/ugurcavusoglu/smartjuice-app.git
cd smartjuice-app

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Emülatör veya gerçek cihazda çalıştır
flutter run

# 4. Release APK oluştur
flutter build apk --release
```

APK dosyası şu konumda oluşur:
```
build/app/outputs/flutter-apk/app-release.apk
```

Bu dosyayı Android cihaza aktarıp kurabilirsin (cihazda "Bilinmeyen kaynaklardan yükleme" açık olmalı).

## Course

CENG318 — Mobile Application Development
