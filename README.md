# NeedU — Silent SOS

![SOS page](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0eyf59jp53a0628xbg81.png)


## Overview

NeedU is a privacy-minded silent SOS app built with **Flutter + Firebase**. It allows a user to silently trigger an emergency alert by holding an SOS button for **3 seconds**, which then:

* Provides haptic confirmation and a snackbar.
* Starts a **30s background audio recording** that is chunked into **5s files** and uploaded immediately to Firebase Storage.
* Shares the user's current location with registered emergency contacts.

---

## Features

* Hold-to-trigger SOS button with animated countdown and particle effects.
* Background audio recording in safe chunks (5s) with immediate upload to Firebase Storage.
* Authentication: Email/password, Google, Apple, and mandatory Phone OTP verification at signup.
* Firestore `users/{uid}` for user profile & emergency contacts; local persistence via `SharedPreferences`.
* Uses a centralized design system: `AppColors`, `AppTypography`, `AppTheme`, `SizeConfig`.

---

## Installation

Follow these steps to run the app locally. Make sure you have Flutter and platform SDKs installed and configured (Android SDK / Xcode).

1. Clone the repo

```bash
git clone <your-repo-url>
cd needu
```

2. Install Dart/Flutter packages

```bash
flutter pub get
```

3. Platform-specific Firebase files

* Android: put `google-services.json` in `android/app/`.
* iOS: put `GoogleService-Info.plist` in `ios/Runner/`.
* Add SHA-1 & SHA-256 keys to Firebase Console for phone auth (Android).

4. Run the app

```bash
# list devices
flutter devices

# run on a specific device (replace <device-id> with `flutter devices` output)
flutter run -d <device-id>
```

5. Notes for background recording on iOS

* Enable Background Modes -> Audio, AirPlay, and Picture in Picture in Xcode for the app target.
* Add required permissions in `Info.plist` for microphone and location access.

---

## How I used Kiro

Kiro is an IDE-integrated assistant tool I tried during development. Here's how I used it:

1. **Scaffolding help:** Kiro generated boilerplate for `sos_page.dart` and `audio_services.dart`, including animation controllers, timer painter, and the singleton service scaffold for recording and uploading.
2. **Prompt refinement:** I iterated inside Kiro to enforce the app's design system (`AppColors`, `SizeConfig`, etc.) and ensure no extra styles leaked in.
3. **In-IDE assistance:** Kiro accelerated code generation and iteration, but I still did platform-specific testing (iOS background modes, Android power settings) manually.
4. **Verification & fixes:** I used Kiro output as a starting point, then refined logic (especially around chunked uploads, permission handling, and upload path naming) with real-device tests.

---

## File structure (high level)

```
lib/
├─ features/
│  ├─ auth/
│  │  ├─ firebase_auth_services.dart
│  │  └─ auth_services.dart
│  ├─ sos/
│  │  ├─ sos_page.dart
│  │  └─ emergency_contacts_widget.dart
│  └─ profile/
├─ services/
│  └─ audio_services.dart
├─ utils/
│  └─ utilis.dart
└─ main.dart
```

---

## Screenshots

![Auth flow preview](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/056iwe6x3g13jk638gh2.png)

![Profile UI preview](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dxpys38fsx3ndcw0r45v.png)

---

## Contributing

Contributions welcome — please open issues/PRs. If you change auth or storage rules, update the README and document the security considerations.

---

## License

MIT License — see `LICENSE` file.
