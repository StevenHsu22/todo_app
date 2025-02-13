# todo_app

A new Flutter project.

## Environment

- macOS 14.6.1
- Flutter 3.29.0 
- Dart 3.7.0
- node.js v20.18.0
- iOS Simulator
- mysql (local)

## requirements

1. [Insatll flutter](https://docs.flutter.dev/get-started/install/macos/mobile-ios)

2. Install dependencies:

```bash
npm install express sequelize mysql2 dotenv
```

3. Add the following to the `pubspec.yaml` file in this document. Then, run `flutter pub get`

```
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.3.  <---- Add this
```

## main project Structure

- todo_app/
  - lib/
    - main.dart 
    - screens/
      - home_screen.dart
  - src/
    - config/
      - database.js
    - models/
      - todo.js
    - controllers/
      - todo.js
    - routes/
      - todo.js
  - server.js
  - .env
  - pubspec.yaml

## Todo

- combine with firebase

```
flutter pub add firebase_core
flutter pub add firebase_auth
```

- use docker compose