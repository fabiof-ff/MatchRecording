#!/bin/bash
# Script di avvio rapido per Match Recording App

echo "🚀 Match Recording App - Flutter Setup"
echo "======================================"
echo ""

# Controlla Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter non trovato nel PATH"
    echo "Aggiungi C:\\flutter\\bin al PATH di Windows"
    exit 1
fi

echo "✅ Flutter trovato"
flutter --version

# Vai alla cartella progetto
echo ""
echo "📁 Cartella progetto: $(pwd)"
echo ""

# Scarica dipendenze
echo "📦 Scaricamento dipendenze..."
flutter pub get

# Controlla errori
if [ $? -ne 0 ]; then
    echo "❌ Errore nel download dipendenze"
    exit 1
fi

echo ""
echo "✅ Dipendenze installate!"
echo ""

# Controlla emulatori
echo "📱 Dispositivi disponibili:"
flutter devices

echo ""
echo "🎮 Comandi disponibili:"
echo ""
echo "  flutter run          - Avvia l'app"
echo "  flutter run -v       - Avvia con log dettagliati"
echo "  flutter emulators    - Lista emulatori"
echo "  flutter analyze      - Controlla errori codice"
echo "  flutter build apk    - Crea APK per Android"
echo ""
echo "✨ Buon divertimento!"
