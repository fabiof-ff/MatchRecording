import Foundation

// MARK: - Data Models
struct Highlight: Identifiable, Codable {
    let id = UUID()
    let timestamp: TimeInterval
    let duration: TimeInterval
    let date: Date
    
    var description: String {
        let minutes = Int(timestamp) / 60
        let seconds = Int(timestamp) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Manager Logic (No AVFoundation)
class MatchLogicManager {
    var matchTime: TimeInterval = 0
    var team1Score: Int = 0
    var team2Score: Int = 0
    var team1Name: String = "Squadra 1"
    var team2Name: String = "Squadra 2"
    var highlights: [Highlight] = []
    var isRecording: Bool = false
    
    func startRecording() {
        isRecording = true
        print("📹 Registrazione iniziata")
    }
    
    func stopRecording() {
        isRecording = false
        print("⏹️ Registrazione fermata")
    }
    
    func addGoalTeam1() {
        guard isRecording else {
            print("❌ Errore: Registrazione non attiva")
            return
        }
        team1Score += 1
        print("⚽ Gol Squadra 1! Score: \(team1Score) - \(team2Score)")
    }
    
    func addGoalTeam2() {
        guard isRecording else {
            print("❌ Errore: Registrazione non attiva")
            return
        }
        team2Score += 1
        print("⚽ Gol Squadra 2! Score: \(team1Score) - \(team2Score)")
    }
    
    func markHighlight() {
        guard isRecording else {
            print("❌ Errore: Registrazione non attiva")
            return
        }
        let highlight = Highlight(
            timestamp: matchTime,
            duration: 10,
            date: Date()
        )
        highlights.append(highlight)
        print("⭐ Highlight marcato al \(highlight.description) (Totali: \(highlights.count))")
    }
    
    func incrementMatchTime(by seconds: TimeInterval = 1) {
        matchTime += seconds
    }
    
    func getTotalHighlightsDuration() -> TimeInterval {
        return highlights.reduce(0) { $0 + $1.duration }
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    func getMatchSummary() -> String {
        let duration = formatTime(matchTime)
        let totalHighlightsDuration = formatTime(getTotalHighlightsDuration())
        let result = team1Score > team2Score ? "\(team1Name) vince" : 
                     team2Score > team1Score ? "\(team2Name) vince" : "Pareggio"
        
        return """
        📊 RIASSUNTO PARTITA
        ━━━━━━━━━━━━━━━━━━━━━━━
        \(team1Name) \(team1Score) - \(team2Score) \(team2Name)
        Risultato: \(result)
        
        ⏱️ Durata: \(duration)
        ⭐ Highlights: \(highlights.count)
        📹 Durata highlights: \(totalHighlightsDuration)
        
        Highlights marcati:
        \(highlights.enumerated().map { i, h in
            "  \(i+1). \(h.description) (+\(Int(h.duration))s)"
        }.joined(separator: "\n"))
        """
    }
}

// MARK: - Tests
print("🧪 INIZIO TEST LOGICA APP\n")

let manager = MatchLogicManager()
manager.team1Name = "Inter"
manager.team2Name = "Milan"

// Test 1: Recording control
print("Test 1: Controllo Registrazione")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
manager.startRecording()
manager.addGoalTeam1() // Dovrebbe funzionare
manager.stopRecording()
manager.addGoalTeam1() // Dovrebbe dare errore
print()

// Test 2: Match simulation
print("Test 2: Simulazione Partita 45min (1º tempo)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
manager.startRecording()
for minute in 1...45 {
    manager.incrementMatchTime(by: 60)
    
    // Simula gol
    if minute == 12 {
        manager.addGoalTeam1()
        manager.markHighlight()
    }
    if minute == 28 {
        manager.addGoalTeam2()
        manager.markHighlight()
    }
    if minute == 35 {
        manager.addGoalTeam2()
        manager.markHighlight()
    }
}

print("Tempo 1º tempo: \(manager.formatTime(manager.matchTime))")
print("Score: \(manager.team1Score) - \(manager.team2Score)")
print()

// Test 3: Pausa
print("Test 3: Pausa")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
manager.stopRecording()
print("Partita in pausa\n")

// Test 4: 2º tempo
print("Test 4: Simulazione Partita 45min (2º tempo)")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
manager.startRecording()
for minute in 46...90 {
    manager.incrementMatchTime(by: 60)
    
    // Simula gol
    if minute == 67 {
        manager.addGoalTeam1()
        manager.markHighlight()
    }
    if minute == 82 {
        manager.addGoalTeam1()
        manager.markHighlight()
    }
}

manager.stopRecording()
print("Tempo 2º tempo: \(manager.formatTime(manager.matchTime))")
print()

// Test 5: Highlights management
print("Test 5: Gestione Highlights")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("Total highlights: \(manager.highlights.count)")
print("Durata totale highlights: \(manager.formatTime(manager.getTotalHighlightsDuration()))")
print()

// Test 6: Final Summary
print(manager.getMatchSummary())

// Test 7: Export simulation
print("\n\nTest 7: Simulazione Export MP4")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
let fileSize = Double(manager.highlights.count) * 25.5 // ~25.5MB per highlight
print("📦 Dimensione file MP4: \(String(format: "%.1f", fileSize))MB")
print("⏱️ Tempo stima export: ~\(Int(fileSize / 50))s (a 50MB/s)")
print("✅ Export simulato completato!")
