# Match Recording - Flutter Project Configuration

## Setup Checklist

- [ ] Flutter installato e in PATH
- [ ] Android Studio con Android SDK
- [ ] Xcode (per iOS)
- [ ] Device o emulatore connesso
- [ ] `flutter pub get` eseguito

## Steps di Configurazione

### 1. Installa Flutter
```bash
# Flutter è stato clonato in C:\flutter
# Aggiungi al PATH di Windows
setx PATH "%PATH%;C:\flutter\bin"

# Verifica installazione
flutter --version
flutter doctor
```

### 2. Setup Emulatore Android
```bash
# Usa Android Studio per creare un emulatore
# O da terminale:
flutter emulators --launch Pixel_3_API_30
```

### 3. Setup iOS (solo su Mac)
```bash
# Apri Xcode e configura Team
open ios/Runner.xcworkspace

# Oppure usa command line
flutter run -d ios
```

### 4. Installa Dipendenze Progetto
```bash
cd C:\Users\fabio\Desktop\APPs\MatchRecording
flutter pub get
flutter pub upgrade
```

### 5. Lancia l'App
```bash
# Su emulatore/device connesso
flutter run

# Con verbose output
flutter run -v

# Hot reload durante sviluppo
# Premi 'r' nel terminale per hot reload
# Premi 'R' per hot restart
```

## Debugging

```bash
# Check dipendenze
flutter pub get

# Analyza codice
flutter analyze

# Format codice
dart format lib/

# Controlla problemi
flutter doctor --android-licenses

# Reset completo
flutter clean
rm -rf pubspec.lock
flutter pub get
```

## Build per Produzione

### Android (APK)
```bash
flutter build apk --release
# File salvato in: build/app/outputs/flutter-apk/app-release.apk
```

### Android (AAB - Play Store)
```bash
flutter build appbundle --release
# File salvato in: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Apri in Xcode: open ios/Runner.xcworkspace
```

## File Importanti

- `pubspec.yaml` - Dipendenze e configurazione
- `lib/main.dart` - Entry point app
- `lib/controllers/match_controller.dart` - Logica principale
- `android/app/src/main/AndroidManifest.xml` - Permessi Android
- `ios/Runner/Info.plist` - Permessi iOS

## Permessi Richiesti

### Android
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS
```
NSCameraUsageDescription = "Fotocamera per registrare partite"
NSMicrophoneUsageDescription = "Microfono per audio partita"
NSPhotoLibraryUsageDescription = "Salva video registrati"
```

## Contatti / Supporto

Flutter: https://flutter.dev
Documentazione: https://docs.flutter.dev
Dart: https://dart.dev
