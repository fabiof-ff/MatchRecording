import SwiftUI

struct ContentView: View {
    @StateObject var recordingManager = VideoRecordingManager()
    @StateObject var overlayManager = OverlayManager()
    @State private var showRecordingView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Match Recording")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Registra e evidenzia i momenti salienti")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Recording Status
                    VStack(spacing: 15) {
                        HStack {
                            Circle()
                                .fill(recordingManager.isRecording ? Color.red : Color.gray)
                                .frame(width: 12, height: 12)
                            Text(recordingManager.isRecording ? "Registrazione in corso" : "Pronto per registrare")
                                .fontWeight(.semibold)
                        }
                        
                        if recordingManager.isRecording {
                            Text("Durata: \(formatTime(recordingManager.recordingDuration))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Overlay Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Impostazioni Overlay")
                            .font(.headline)
                        
                        HStack {
                            Text("Tempo partita:")
                            Spacer()
                            Text("\(formatTime(overlayManager.matchTime))")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Squadra 1:")
                            Spacer()
                            TextField("Gol", value: $overlayManager.team1Score, format: .number)
                                .frame(width: 50)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack {
                            Text("Squadra 2:")
                            Spacer()
                            TextField("Gol", value: $overlayManager.team2Score, format: .number)
                                .frame(width: 50)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(10)
                    
                    // Highlights Count
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Highlights marcati: \(recordingManager.highlights.count)")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 10) {
                        NavigationLink(destination: RecordingView(
                            recordingManager: recordingManager,
                            overlayManager: overlayManager
                        )) {
                            HStack {
                                Image(systemName: "video.circle.fill")
                                Text("Inizia Registrazione")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: HighlightsView(recordingManager: recordingManager)) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("I Miei Highlights (\(recordingManager.highlights.count))")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 2))
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
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
}

#Preview {
    ContentView()
}
