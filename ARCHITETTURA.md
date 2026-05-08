# 🏗️ ARCHITETTURA - Match Recording App

**Documento di Architettura Tecnica**  
**Data:** 2026-05-08  
**Versione:** 1.0  
**Stato:** In Sviluppo - Fase 9 (Device Testing)  

---

## 📑 Indice

1. [Panoramica Generale](#panoramica-generale)
2. [Stack Tecnologico](#stack-tecnologico)
3. [Architettura del Sistema](#architettura-del-sistema)
4. [Struttura del Progetto](#struttura-del-progetto)
5. [Componenti Principali](#componenti-principali)
6. [Flusso dei Dati](#flusso-dei-dati)
7. [Gestione dello Stato](#gestione-dello-stato)
8. [Modelli di Dati](#modelli-di-dati)
9. [Layer di Persistenza](#layer-di-persistenza)
10. [Integrazioni](#integrazioni)
11. [Pattern e Best Practices](#pattern-e-best-practices)
12. [Considerazioni di Performance](#considerazioni-di-performance)
13. [Roadmap di Implementazione](#roadmap-di-implementazione)

---

## 🎯 Panoramica Generale

### Descrizione del Progetto

**Match Recording App** è un'applicazione mobile multi-piattaforma che permette agli utenti di:
- 📹 Registrare video di partite di calcio
- ⏱️ Tracciare i minuti di gioco in tempo reale
- 🎯 Registrare i punteggi e i marcatori
- ⭐ Marcare i momenti salienti (gol, azioni notevoli)
- 📤 Esportare video in MP4 con overlay degli highlight
- 📱 Sincronizzare i dati tra dispositivi

### Target Platform

- **Android** (min API level 24+)
- **iOS** (min version 13.0+)
- **Web** (supporto secondario)

### Obiettivi Architetturali

1. ✅ **Modularità**: Componenti indipendenti e riutilizzabili
2. ✅ **Scalabilità**: Facile aggiunta di nuove funzionalità
3. ✅ **Testabilità**: Logica separata dalla UI
4. ✅ **Performance**: Gestione efficiente della memoria e batteria
5. ✅ **Manutenibilità**: Codice pulito e ben documentato
6. ✅ **Reattività**: UI responsive e fluida

---

## 🛠️ Stack Tecnologico

### Framework Principale

| Componente | Tecnologia | Versione | Ruolo |
|-----------|-----------|---------|-------|
| **Framework** | Flutter | 3.0+ | Framework multipiattaforma |
| **Linguaggio** | Dart | 3.0+ | Linguaggio di programmazione |
| **SDK** | Flutter SDK | Latest | Development Kit |

### Dipendenze Principali

#### State Management
```yaml
get: ^4.6.5
```
- State management reattivo
- Routing e navigazione
- Dependency Injection
- Event bus

#### Multimedia
```yaml
camera: ^0.10.5          # Accesso alla fotocamera
camera_web: ^0.3.2       # Supporto web per fotocamera
video_player: ^2.8.0     # Riproduzione video
ffmpeg_kit_flutter: ^6.0.2  # Elaborazione video
```

#### Gestione File e Storage
```yaml
path_provider: ^2.1.0    # Path per file e cache
```

#### Utility
```yaml
cupertino_icons: ^1.0.8  # Icone iOS
intl: ^0.19.0            # Internazionalizzazione
uuid: ^4.0.0             # Generazione ID univoci
```

### Architettura UI

- **Material Design 3**: Interfaccia moderna e coerente
- **Responsive Layout**: Adattamento a diversi schermi
- **Dark Mode Ready**: Supporto tema scuro

---

## 🏛️ Architettura del Sistema

### Modello Architetturale: MVC + GetX

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│                    (UI - Flutter Widgets)                     │
│  ┌──────────────────┬──────────────────┬──────────────────┐  │
│  │ Home Screen      │ Recording Screen │ Highlights Screen│  │
│  └──────────────────┴──────────────────┴──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC LAYER                       │
│                  (Controllers - GetX)                          │
│                                                                 │
│    ┌──────────────────────────────────────────────────┐       │
│    │ MatchController                                  │       │
│    │ - Gestione dello stato di registrazione          │       │
│    │ - Logica di timing (cronometro)                  │       │
│    │ - Gestione punteggi                              │       │
│    │ - Tracciamento highlight                         │       │
│    └──────────────────────────────────────────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                     DATA LAYER                                │
│         (Models, Services, Repositories)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ Highlight    │  │ Camera Svc   │  │ Video Svc    │       │
│  │ Model        │  │              │  │              │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│  ┌──────────────┐  ┌──────────────┐                          │
│  │ Export Svc   │  │ File Storage │                          │
│  │ (FFmpeg)     │  │              │                          │
│  └──────────────┘  └──────────────┘                          │
│                                                                 │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                 PERSISTENCE & NATIVE LAYER                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ File System  │  │ Camera API   │  │ Video Codec  │       │
│  │              │  │ (Platform)   │  │              │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────┘
```

### Separazione dei Livelli

#### **Presentation Layer (UI)**
- **Responsabilità**: Rendering e interazione con l'utente
- **Componenti**: Widgets, Screens, UI elements
- **Comunicazione**: Attraverso GetX Controllers (bindings)
- **Indipendenza**: Non contiene logica di business

#### **Business Logic Layer (Controller)**
- **Responsabilità**: Logica applicativa e gestione dello stato
- **Componenti**: GetX Controllers
- **Stato Reattivo**: Utilizzazione di RxValues (.obs)
- **Indipendenza**: Non contiene codice UI

#### **Data Layer (Services & Models)**
- **Responsabilità**: Accesso ai dati e alle risorse
- **Componenti**: Service classes, Data models, Repositories
- **Interfacce**: Definite per permettere mock e testing

#### **Platform/Native Layer**
- **Responsabilità**: Accesso alle API native (camera, storage)
- **Platform Channels**: Per comunicazione Dart ↔ Native
- **Plugins**: camera, video_player, ffmpeg_kit_flutter

---

## 📁 Struttura del Progetto

### Layout Fisico

```
MatchRecording/
│
├── lib/                                    # Codice Dart principale
│   ├── main.dart                          # Entry point dell'app
│   ├── match_recording_app.dart           # App root widget
│   │
│   ├── controllers/
│   │   └── match_controller.dart          # State manager principale
│   │       ├── Proprietà reactive (.obs)
│   │       ├── Metodi di business logic
│   │       └── Event handlers
│   │
│   ├── models/
│   │   ├── highlight.dart                 # Data model per highlight
│   │   ├── match_session.dart             # (Future) Sessione di match
│   │   ├── team.dart                      # (Future) Informazioni team
│   │   └── serializers/                   # (Future) Serializzazione
│   │
│   ├── services/
│   │   ├── camera_service.dart            # (Fase 10) Gestione camera
│   │   ├── video_service.dart             # (Fase 10) Elaborazione video
│   │   ├── export_service.dart            # (Fase 11) Export MP4
│   │   ├── storage_service.dart           # File storage
│   │   └── database_service.dart          # (Fase 12) Persistenza
│   │
│   ├── screens/
│   │   ├── home_screen.dart               # Schermata principale
│   │   ├── recording_screen.dart          # Schermata registrazione
│   │   ├── highlights_screen.dart         # Schermata highlight
│   │   ├── player_screen.dart             # (Future) Riproduzione
│   │   └── settings_screen.dart           # (Future) Impostazioni
│   │
│   ├── widgets/
│   │   ├── custom_button.dart             # (Future) Widget custom
│   │   ├── timer_display.dart             # (Future) Display timer
│   │   ├── score_display.dart             # (Future) Display punteggio
│   │   └── overlay_painter.dart           # (Future) Canvas overlay
│   │
│   ├── theme/
│   │   ├── app_colors.dart                # (Future) Palette colori
│   │   ├── app_typography.dart            # (Future) Stili testo
│   │   └── app_theme.dart                 # (Future) Tema globale
│   │
│   ├── utils/
│   │   ├── constants.dart                 # (Future) Costanti app
│   │   ├── logger.dart                    # (Future) Logging
│   │   ├── validators.dart                # (Future) Validatori
│   │   └── extensions.dart                # (Future) Estensioni Dart
│   │
│   └── bindings/                           # (Future) Binding di dipendenze
│       └── app_binding.dart               # Iniezione globale
│
├── test/                                   # Test Dart/Flutter
│   ├── widget_test.dart                   # Test widget (auto-generated)
│   ├── registration_simulation_test.dart  # Test simulazione registrazione
│   ├── match_controller_test.dart         # (Future) Test controller
│   └── services_test.dart                 # (Future) Test servizi
│
├── android/                                # Codice Android nativo
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml        # Permessi e configurazione
│   │       ├── kotlin/                    # (Future) Codice Kotlin
│   │       └── res/                       # Risorse Android
│   └── build.gradle
│
├── ios/                                    # Codice iOS nativo
│   ├── Runner/
│   │   ├── Info.plist                     # Configurazione iOS
│   │   ├── Assets.xcassets/               # Asset iOS
│   │   └── Runner.swift                   # (Future) Codice Swift
│   └── Podfile
│
├── web/                                    # Supporto web (Future)
│   ├── index.html
│   ├── main.dart                          # Entry point web
│   └── manifest.json
│
├── Documentation/                          # Documentazione progetto
│   ├── START_HERE.md
│   ├── QUICKSTART.md
│   ├── README.md
│   ├── SETUP.md
│   ├── PROJECT_SUMMARY.md
│   ├── ARCHITETTURA.md                    # ← Questo file
│   ├── TEST_RECORDING_GUIDE.md
│   ├── TEST_REPORT.md
│   ├── IOS_FIXES.md
│   └── DEVICE_TESTING_PHASE.md
│
├── Testing/                                # Test infrastructure
│   ├── test_recording.html                # Test interattivo web
│   ├── test_recording_advanced.html       # (Future) Test avanzati
│   ├── start_test_server.py               # Server Python
│   ├── run_test_server.py
│   └── TEST_SERVER_MENU.bat
│
├── .github/workflows/                      # (Future) CI/CD
│   ├── flutter-test.yml                   # Test automatici
│   └── deploy.yml                         # Deploy
│
├── pubspec.yaml                            # Dipendenze Flutter
├── pubspec.lock                            # Lock file dipendenze
├── analysis_options.yaml                   # Linter configuration
├── .gitignore                              # Git ignore rules
├── .git/                                   # Repository git
│
└── Config Files
    ├── launch.json                         # (Future) VS Code debug
    ├── settings.json                       # (Future) VS Code settings
    └── build.gradle                        # Gradle configuration
```

### Naming Conventions

| Tipo | Convenzione | Esempio |
|------|-----------|---------|
| **File** | snake_case | `match_controller.dart` |
| **Classi** | PascalCase | `MatchController`, `HomeScreen` |
| **Variabili** | camelCase | `isRecording`, `totalScore` |
| **Costanti** | UPPER_SNAKE_CASE | `MAX_VIDEO_LENGTH`, `API_BASE_URL` |
| **Private** | Prefisso `_` | `_internalMethod()`, `_privateVar` |
| **Booleani** | Prefisso is/has | `isRecording`, `hasPermission` |

---

## 🎛️ Componenti Principali

### 1. MatchController (Business Logic)

```dart
class MatchController extends GetxController {
  // ====== STATE (Reactive) ======
  final RxBool isRecording = false.obs;
  final RxInt elapsedSeconds = 0.obs;
  final RxInt matchMinute = 0.obs;
  final RxInt homeTeamScore = 0.obs;
  final RxInt awayTeamScore = 0.obs;
  final RxList<Highlight> highlights = <Highlight>[].obs;
  
  // ====== BUSINESS LOGIC METHODS ======
  void startRecording();
  void stopRecording();
  void pauseRecording();
  void resumeRecording();
  
  void incrementHomeTeamScore();
  void decrementHomeTeamScore();
  void incrementAwayTeamScore();
  void decrementAwayTeamScore();
  
  void addHighlight(String type, String description);
  void removeHighlight(String highlightId);
  void updateHighlight(String highlightId, Highlight updatedHighlight);
  
  void resetMatch();
  void exportHighlights();
  
  // ====== LIFECYCLE ======
  @override
  void onInit();
  
  @override
  void onClose();
}
```

**Caratteristiche**:
- ✅ State completamente reattivo (Rx)
- ✅ Separazione tra logica e UI
- ✅ Metodi pubblici per azioni
- ✅ Nessuna dipendenza da Widget
- ✅ Lifecycle management

### 2. Data Models

#### Highlight Model
```dart
class Highlight {
  final String id;
  final int timestamp;        // Secondo in cui è stato marcato
  final String type;          // 'goal', 'foul', 'save', 'action'
  final String description;
  final DateTime createdAt;
  
  Highlight({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.createdAt,
  });
  
  // Serialization (per future use)
  Map<String, dynamic> toJson() { ... }
  factory Highlight.fromJson(Map<String, dynamic> json) { ... }
}
```

#### MatchSession Model (Future)
```dart
class MatchSession {
  final String id;
  final String videoPath;
  final DateTime startTime;
  final DateTime? endTime;
  final String homeTeam;
  final String awayTeam;
  final int finalHomeScore;
  final int finalAwayScore;
  final List<Highlight> highlights;
  
  // Methods
  Duration get duration;
  Map<String, dynamic> toJson();
}
```

### 3. Screen Components

#### HomeScreen
- **Scopo**: Punto di partenza dell'app
- **UI**: Menu principale, start recording button
- **Logica**: Navigazione verso recording screen

#### RecordingScreen
- **Scopo**: Interfaccia principale di registrazione
- **UI**: 
  - Video preview (da camera o placeholder)
  - Timer (cronometro)
  - Score display (punteggi)
  - Highlight buttons (marcare momenti)
- **Logica**: 
  - Cattura input utente
  - Binding a MatchController
  - Overlay rendering

#### HighlightsScreen
- **Scopo**: Revisione e export dei momenti salienti
- **UI**:
  - Lista dei highlight registrati
  - Preview timeline
  - Export options
- **Logica**:
  - Visualizzazione highlight
  - Configurazione export
  - Lancio servizio export

### 4. Services (Layer dei Dati)

#### Camera Service (Fase 10)
```dart
abstract class CameraService {
  Future<void> initialize();
  Future<void> startRecording(String outputPath);
  Future<void> stopRecording();
  Future<void> dispose();
}

class CameraServiceImpl implements CameraService {
  // Implementazione specifica
}
```

#### Video Service (Fase 10)
```dart
abstract class VideoService {
  Future<VideoInfo> getVideoInfo(String videoPath);
  Future<void> createThumbnail(String videoPath, String outputPath);
}
```

#### Export Service (Fase 11)
```dart
abstract class ExportService {
  Future<String> exportWithHighlights(
    String inputVideo,
    List<Highlight> highlights,
  );
}

class FFmpegExportService implements ExportService {
  // Usa FFmpeg per elaborazione
}
```

#### Storage Service
```dart
abstract class StorageService {
  Future<String> getAppDocumentDirectory();
  Future<String> getVideoDirectory();
  Future<List<File>> listRecordings();
  Future<void> deleteRecording(String path);
}
```

---

## 🔄 Flusso dei Dati

### Flusso di Registrazione

```
User Action (Press Record)
        ↓
HomeScreen.startRecording()
        ↓
MatchController.startRecording()
        ↓
  ├─→ CameraService.startRecording()
  │        ↓
  │   Camera Hardware
  │
  └─→ isRecording.value = true
        ↓
  Reactive Update
        ↓
  RecordingScreen rebuilds
```

### Flusso di Aggiunta Highlight

```
User Action (Press Goal Button)
        ↓
RecordingScreen.onGoalPressed()
        ↓
MatchController.addHighlight('goal', 'Ronaldo')
        ↓
  ├─→ Calcola timestamp corrente
  │
  └─→ highlights.add(Highlight(...))
        ↓
  Reactive Update
        ↓
  HighlightsScreen rebuilds
        ↓
  UI mostra nuovo highlight
```

### Flusso di Export

```
User Action (Export)
        ↓
HighlightsScreen.export()
        ↓
MatchController.exportHighlights()
        ↓
ExportService.exportWithHighlights()
        ↓
  ├─→ Leggi video originale
  │
  ├─→ Prepara comandi FFmpeg
  │   (Aggiungi overlay, testo, timeline)
  │
  └─→ Esegui FFmpeg
        ↓
  Video elaborato
        ↓
  Salva in Storage
        ↓
  Share dialog
```

---

## 🎮 Gestione dello Stato

### GetX Reactive Programming

#### RxValues (Proprietà Osservabili)

```dart
// Definizione
final RxBool isRecording = false.obs;
final RxInt matchMinute = 0.obs;

// Accesso al valore
print(isRecording.value);  // false
print(matchMinute.value);  // 0

// Modifica del valore (trigger rebuild)
isRecording.value = true;
matchMinute.value++;

// Binding nella UI
Obx(() => Text('Recording: ${isRecording.value}'))
```

#### Reactive Lists

```dart
final RxList<Highlight> highlights = <Highlight>[].obs;

// Aggiunta elemento (trigger rebuild)
highlights.add(newHighlight);

// Rimozione elemento
highlights.removeWhere((h) => h.id == highlightId);

// Binding nella UI
Obx(() => ListView(
  children: highlights.map((h) => HighlightTile(h)).toList(),
))
```

### Lifecycle del Controller

```dart
class MatchController extends GetxController {
  @override
  void onInit() {
    // Chiamato quando controller è inizializzato
    // - Inizializzare timer
    // - Caricare dati salvati
    // - Settare listener
  }
  
  @override
  void onReady() {
    // Chiamato dopo prima build
    // - Operazioni che richiedono UI context
  }
  
  @override
  void onClose() {
    // Chiamato prima della distruzione
    // - Cancellare timer
    // - Chiudere stream
    // - Liberare risorse
  }
}
```

### State Update Pattern

```dart
// Pattern 1: Update Semplice
matchMinute.value++;  // Trigger rebuild

// Pattern 2: Update Complesso con refresh
highlights.assignAll(newList);  // Rimpiazza lista e notifica

// Pattern 3: Update con Map
matchData({
  'minute': 45,
  'homeScore': 2,
  'awayScore': 1,
});
```

---

## 📊 Modelli di Dati

### Highlight Model (Completo)

```dart
class Highlight {
  final String id;
  final int timestamp;           // Secondo nel video
  final String type;             // 'goal', 'foul', 'save', 'action'
  final String description;      // Descrizione libera
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;  // Dati aggiuntivi
  
  Highlight({
    String? id,
    required this.timestamp,
    required this.type,
    required this.description,
    DateTime? createdAt,
    this.metadata,
  }) : id = id ?? Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
  
  // Serialization per database
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'type': type,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };
  
  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
    id: json['id'],
    timestamp: json['timestamp'],
    type: json['type'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    metadata: json['metadata'],
  );
  
  // Copy with per immutabilità
  Highlight copyWith({
    String? id,
    int? timestamp,
    String? type,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) => Highlight(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    type: type ?? this.type,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    metadata: metadata ?? this.metadata,
  );
}
```

### MatchSession Model (Struttura)

```dart
class MatchSession {
  final String id;
  final String videoPath;
  final DateTime startTime;
  final DateTime? endTime;
  final String homeTeam;
  final String awayTeam;
  final int finalHomeScore;
  final int finalAwayScore;
  final List<Highlight> highlights;
  final Map<String, dynamic> metadata;
  
  MatchSession({
    String? id,
    required this.videoPath,
    required this.startTime,
    this.endTime,
    required this.homeTeam,
    required this.awayTeam,
    required this.finalHomeScore,
    required this.finalAwayScore,
    required this.highlights,
    this.metadata = const {},
  }) : id = id ?? Uuid().v4();
  
  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
  
  bool get isRecording => endTime == null;
  
  int get totalMinutes => (duration.inSeconds ~/ 60);
}
```

---

## 💾 Layer di Persistenza

### Fase 12: Database Layer (In Pianificazione)

#### Opzioni di Storage

```
┌─────────────────────────────────────┐
│ PERSISTENCE OPTIONS                 │
├─────────────────────────────────────┤
│ 1. Hive (Key-value store)           │ ← Consigliato
│    - Veloce e leggero               │
│    - Ottimo per mobile              │
│    - Typesafe                       │
│                                     │
│ 2. SQLite (Relazionale)             │ ← Alternativa
│    - Query complesse                │
│    - Relazioni tra tabelle          │
│    - Più overhead                   │
│                                     │
│ 3. File System (JSON)               │ ← Semplice
│    - No database setup              │
│    - Limitato per query             │
│    - Meno performante               │
└─────────────────────────────────────┘
```

#### Struttura Database (Hive)

```dart
// Boxes necessarie
const String MATCHES_BOX = 'matches';
const String HIGHLIGHTS_BOX = 'highlights';
const String SETTINGS_BOX = 'settings';

// Initialize
void initDatabase() async {
  Hive.registerAdapter(MatchSessionAdapter());
  Hive.registerAdapter(HighlightAdapter());
  
  await Hive.openBox<MatchSession>(MATCHES_BOX);
  await Hive.openBox<Highlight>(HIGHLIGHTS_BOX);
  await Hive.openBox<Map>(SETTINGS_BOX);
}

// Usage
var matchBox = Hive.box<MatchSession>(MATCHES_BOX);
matchBox.put('match_id', matchSession);
var retrievedMatch = matchBox.get('match_id');
```

#### Repository Pattern

```dart
abstract class MatchRepository {
  Future<void> saveMatch(MatchSession match);
  Future<MatchSession?> getMatch(String id);
  Future<List<MatchSession>> getAllMatches();
  Future<void> deleteMatch(String id);
  Future<void> updateMatch(MatchSession match);
}

class HiveMatchRepository implements MatchRepository {
  final Box<MatchSession> _box;
  
  HiveMatchRepository(this._box);
  
  @override
  Future<void> saveMatch(MatchSession match) async {
    await _box.put(match.id, match);
  }
  
  @override
  Future<MatchSession?> getMatch(String id) async {
    return _box.get(id);
  }
  
  // ... implementazione altri metodi
}
```

---

## 🔗 Integrazioni

### 1. Camera Integration (Fase 10)

```dart
// Flusso di integrazione
class RecordingScreen extends StatefulWidget {
  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late CameraController _cameraController;
  
  @override
  void initState() {
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    
    await _cameraController.initialize();
  }
  
  @override
  void dispose() {
    _cameraController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return CameraPreview(_cameraController);
  }
}
```

### 2. FFmpeg Integration (Fase 11)

```dart
// Esportazione con FFmpeg
class FFmpegExportService {
  Future<String> exportWithHighlights(
    String inputVideo,
    List<Highlight> highlights,
  ) async {
    // Prepara comandi FFmpeg
    String command = _buildFFmpegCommand(inputVideo, highlights);
    
    // Esegui elaborazione
    final rc = await FFmpegKit.execute(command);
    
    // Gestisci risultato
    if (rc == 0) {
      return outputPath;
    } else {
      throw Exception('FFmpeg failed: $rc');
    }
  }
  
  String _buildFFmpegCommand(String input, List<Highlight> highlights) {
    // Costruisci comandi per overlay, testo, etc.
    return '-i $input -filter_complex ... -c:a aac output.mp4';
  }
}
```

### 3. Platform Channels (Future - Per Funzionalità Native)

```dart
// Dart side
const platform = MethodChannel('com.matchrecording/camera');

Future<void> startNativeRecording() async {
  try {
    final result = await platform.invokeMethod('startRecording');
  } catch (e) {
    print('Error: $e');
  }
}
```

```kotlin
// Kotlin side (Android)
class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      "com.matchrecording/camera"
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "startRecording" -> {
          startRecording()
          result.success("Recording started")
        }
      }
    }
  }
}
```

---

## 🎯 Pattern e Best Practices

### 1. Dependency Injection (GetX)

```dart
// Definizione
void setupServiceLocator() {
  Get.put<MatchController>(MatchController());
  Get.put<CameraService>(CameraServiceImpl());
  Get.put<ExportService>(FFmpegExportService());
  Get.put<StorageService>(StorageServiceImpl());
}

// Utilizzo in Widget
final controller = Get.find<MatchController>();

// Utilizzo in Controller
class MatchController extends GetxController {
  final CameraService _cameraService = Get.find();
  
  void startRecording() {
    _cameraService.startRecording(videoPath);
  }
}
```

### 2. Error Handling

```dart
// Pattern comune
Future<void> performAction() async {
  try {
    // Operazione
    await riskyOperation();
    Get.snackbar('Success', 'Operazione completata');
  } on PermissionException catch (e) {
    Get.snackbar('Permission Error', e.message);
  } on StorageException catch (e) {
    Get.snackbar('Storage Error', 'Spazio insufficiente');
  } catch (e) {
    Get.snackbar('Error', 'Errore sconosciuto');
  }
}
```

### 3. Testability

```dart
// Service Interface (Mockable)
abstract class CameraService {
  Future<void> startRecording(String path);
}

// Test Implementation
class MockCameraService extends Mock implements CameraService {}

// Test
void main() {
  test('MatchController starts recording', () async {
    final mockCamera = MockCameraService();
    final controller = MatchController(cameraService: mockCamera);
    
    await controller.startRecording();
    
    verify(mockCamera.startRecording(any)).called(1);
  });
}
```

### 4. Widget Best Practices

```dart
// ❌ Cattiva pratica
class RecordingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<MatchController>();
    return Text('${controller.matchMinute}');  // Non rebuilda
  }
}

// ✅ Buona pratica
class RecordingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<MatchController>();
      return Text('${controller.matchMinute.value}');  // Rebuilda
    });
  }
}
```

---

## ⚡ Considerazioni di Performance

### Memory Management

```dart
// Problem: Memory leak
class RecordingScreen extends StatefulWidget {
  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late StreamSubscription _subscription;
  
  @override
  void initState() {
    _subscription = eventStream.listen((event) {
      // Handle event
    });
    // ❌ Memory leak: subscription non cancellata
  }
  
  @override
  void dispose() {
    _subscription.cancel();  // ✅ Cancella subscription
    super.dispose();
  }
}
```

### Battery Optimization

```dart
// Video recording è intensivo
// Strategie di ottimizzazione:

1. Usare risoluzioni appropriate
   - Full HD (1920x1080) per most cases
   - 4K solo se necessario

2. Limitare frame rate
   - 30 FPS standard
   - 60 FPS solo per slow-motion

3. Managedcodec selection
   - H.264 per compatibilità
   - HEVC per better compression

4. Disable unnecessary features
   - GPS tracking (se non necessario)
   - Background processing
```

### Storage Optimization

```dart
// Video può essere grande
// Strategie:

1. Compression durante export
   - Bitrate: 5-10 Mbps
   - Codec: H.264 con B-frames

2. Cleanup automatico
   - Elimina temp files
   - Archivia vecchi video

3. Cloud sync (future)
   - Upload in background
   - Incremental sync
```

---

## 🗺️ Roadmap di Implementazione

### Fase 9: Device/Emulator Testing (**ATTUALE**)
- [ ] Setup Android emulator
- [ ] Setup iOS simulator
- [ ] Build APK/IPA
- [ ] Test UI su device
- **Timeline**: 1-2 ore

### Fase 10: Camera Integration
- [ ] Implement CameraService
- [ ] Live preview rendering
- [ ] Video recording
- [ ] Test on device
- **Timeline**: 2-3 ore

### Fase 11: Video Processing
- [ ] FFmpeg integration
- [ ] Overlay rendering
- [ ] MP4 export
- [ ] Quality testing
- **Timeline**: 3-4 ore

### Fase 12: Persistence Layer
- [ ] Hive setup
- [ ] Database models
- [ ] Repository pattern
- [ ] Data migration
- **Timeline**: 2-3 ore

### Fase 13: Production Release
- [ ] Performance optimization
- [ ] Bug fixes
- [ ] App store setup
- [ ] Release
- **Timeline**: 2-3 giorni

---

## 📱 Platform-Specific Considerations

### Android

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- Min API 24 -->
<uses-sdk
  android:minSdkVersion="24"
  android:targetSdkVersion="34" />
```

### iOS

```xml
<!-- Info.plist -->
<key>NSCameraUsageDescription</key>
<string>L'app utilizza la fotocamera per registrare video di partite</string>

<key>NSMicrophoneUsageDescription</key>
<string>L'app utilizza il microfono per audio durante le registrazioni</string>

<!-- Min iOS 13.0 -->
<key>MinimumOSVersion</key>
<string>13.0</string>
```

---

## 🧪 Testing Strategy

### Unit Tests
```dart
// Test business logic
test('MatchController increments score', () {
  final controller = MatchController();
  controller.incrementHomeTeamScore();
  expect(controller.homeTeamScore.value, 1);
});
```

### Widget Tests
```dart
// Test UI
testWidgets('Recording button appears on home screen', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.byIcon(Icons.videocam), findsOneWidget);
});
```

### Integration Tests
```dart
// Test full flows
void main() {
  group('Recording Flow', () {
    testWidgets('User can record and add highlights', (tester) async {
      // Full flow test
    });
  });
}
```

---

## 🚀 Deployment

### Build Process

```bash
# Android APK
flutter build apk --release

# iOS IPA
flutter build ios --release

# Web
flutter build web --release
```

### App Store Submission

1. **Google Play Store**
   - Build signed APK
   - Create store listing
   - Add screenshots/description
   - Submit for review

2. **Apple App Store**
   - Build signed IPA
   - Create app record
   - Add screenshots/description
   - Submit for review (3-5 giorni)

---

## 📚 Documentazione Correlata

- `START_HERE.md` - Inizio rapido
- `QUICKSTART.md` - Setup veloce
- `PROJECT_SUMMARY.md` - Sommario progetto
- `PROJECT_STATUS.md` - Status attuale
- `SETUP.md` - Environment setup
- `TEST_RECORDING_GUIDE.md` - Guida test
- `DEVICE_TESTING_PHASE.md` - Test su device

---

## 🔍 Diagrammi Architetturali Aggiuntivi

### Diagramma di Sequenza: Start Recording

```
User        HomeScreen      Controller      CameraService      Native API
 |               |               |                |                 |
 |--Tap Record-->|               |                |                 |
 |               |--startRec()-->|                |                 |
 |               |               |--init()--------|                 |
 |               |               |                |--requestCamera-->|
 |               |               |                |<--granted--------|
 |               |               |<--init ok-----|                 |
 |               |               |--record()-----|--startRecording->|
 |               |               |<--recording---|<--started--------|
 |               |<--state change|                |                 |
 |<--UI updates--|               |                |                 |
```

### Diagramma di Dipendenza

```
┌─────────────────────────────────────┐
│         HomeScreen                   │
└─────────────┬───────────────────────┘
              │
              ├──depends on──→ MatchController
              │
              └──depends on──→ GetX (routing)
                                │
                    ┌───────────┴───────────────┐
                    │                           │
            MatchController              CameraService
                    │                      │    │
                    ├──depends on──→ StorageService
                    │
            RecordingScreen
                    │
            HighlightsScreen
                    │
            ExportService (FFmpeg)
```

---

## 📞 Support e Contatti

Per domande su questa architettura, consultare:
- **GitHub Issues**: fabiof-ff/MatchRecording/issues
- **Documentation**: Cartella Documentation/
- **Project Status**: PROJECT_STATUS.md

---

**Versione**: 1.0  
**Data Creazione**: 2026-05-08  
**Ultimo Aggiornamento**: 2026-05-08  
**Autore**: Fabio  
**Status**: ✅ Approvato e Attivo  

---

*Questo documento è vivente e sarà aggiornato man mano che il progetto progredisce attraverso le diverse fasi di sviluppo.*
