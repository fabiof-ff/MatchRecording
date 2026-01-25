import Combine

class OverlayManager: ObservableObject {
    @Published var matchTime: TimeInterval = 0
    @Published var team1Score: Int = 0
    @Published var team2Score: Int = 0
    @Published var team1Name: String = "Squadra 1"
    @Published var team2Name: String = "Squadra 2"
    @Published var showOverlay: Bool = true
    
    @Published var overlayOpacity: Double = 0.8
    @Published var overlayPosition: OverlayPosition = .bottomRight
    @Published var showTimer: Bool = true
    @Published var showScore: Bool = true
    
    private var timerTask: Task<Void, Never>?
    
    func startTimer() {
        stopTimer()
        
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                
                DispatchQueue.main.async {
                    self.matchTime += 0.1
                }
            }
        }
    }
    
    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
    
    func resetTimer() {
        stopTimer()
        DispatchQueue.main.async {
            self.matchTime = 0
        }
    }
    
    func addGoalTeam1() {
        team1Score += 1
    }
    
    func addGoalTeam2() {
        team2Score += 1
    }
    
    func resetScore() {
        team1Score = 0
        team2Score = 0
    }
    
    deinit {
        stopTimer()
    }
}

enum OverlayPosition {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case center
}
