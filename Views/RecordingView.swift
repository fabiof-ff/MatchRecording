import SwiftUI
import AVFoundation

struct RecordingView: View {
    @ObservedObject var recordingManager: VideoRecordingManager
    @ObservedObject var overlayManager: OverlayManager
    @Environment(\.dismiss) var dismiss
    @State private var cameraPreviewContainer: UIView?
    @State private var isFirstAppear = true
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(
                recordingManager: recordingManager,
                onAppear: { setupCamera() }
            )
            .ignoresSafeArea()
            
            VStack {
                // Top Controls
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Recording Indicator
                    if recordingManager.isRecording {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .scaleEffect(recordingManager.isRecording ? 1.0 : 0.8)
                                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: recordingManager.isRecording)
                            
                            Text(formatTime(recordingManager.recordingDuration))
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                    }
                }
                .padding()
                
                Spacer()
                
                // Live Overlay
                if overlayManager.showOverlay {
                    VStack(spacing: 8) {
                        // Match Time
                        if overlayManager.showTimer {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                Text(formatTime(overlayManager.matchTime))
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.semibold)
                            }
                            .padding(6)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        
                        // Score
                        if overlayManager.showScore {
                            HStack(spacing: 12) {
                                VStack(alignment: .center, spacing: 2) {
                                    Text(overlayManager.team1Name)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                    Text("\(overlayManager.team1Score)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                    .frame(height: 20)
                                    .background(Color.white)
                                
                                VStack(alignment: .center, spacing: 2) {
                                    Text(overlayManager.team2Name)
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                    Text("\(overlayManager.team2Score)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
                
                // Bottom Controls
                VStack(spacing: 12) {
                    // Score Control
                    HStack(spacing: 12) {
                        // Team 1
                        VStack(spacing: 4) {
                            Text(overlayManager.team1Name)
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Button(action: { overlayManager.team1Score = max(0, overlayManager.team1Score - 1) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                }
                                
                                Text("\(overlayManager.team1Score)")
                                    .font(.headline)
                                    .frame(width: 30)
                                
                                Button(action: { overlayManager.addGoalTeam1() }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        // Team 2
                        VStack(spacing: 4) {
                            Text(overlayManager.team2Name)
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Button(action: { overlayManager.team2Score = max(0, overlayManager.team2Score - 1) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                }
                                
                                Text("\(overlayManager.team2Score)")
                                    .font(.headline)
                                    .frame(width: 30)
                                
                                Button(action: { overlayManager.addGoalTeam2() }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                }
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        // Highlight Button
                        Button(action: { recordingManager.markHighlight() }) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Highlight")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                        }
                        .disabled(!recordingManager.isRecording)
                        .opacity(recordingManager.isRecording ? 1.0 : 0.5)
                        
                        // Record/Stop Button
                        Button(action: {
                            if recordingManager.isRecording {
                                recordingManager.stopRecording()
                                overlayManager.stopTimer()
                            } else {
                                recordingManager.startRecording()
                                overlayManager.startTimer()
                            }
                        }) {
                            HStack {
                                Image(systemName: recordingManager.isRecording ? "stop.circle.fill" : "record.circle.fill")
                                Text(recordingManager.isRecording ? "Stop" : "Registra")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(recordingManager.isRecording ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .fontWeight(.semibold)
                        }
                    }
                    .padding()
                }
                .background(Color.black.opacity(0.4))
            }
        }
        .onAppear {
            if isFirstAppear {
                isFirstAppear = false
            }
        }
        .onDisappear {
            if recordingManager.isRecording {
                recordingManager.stopRecording()
            }
            overlayManager.stopTimer()
            recordingManager.stopCameraPreview()
        }
    }
    
    private func setupCamera() {
        recordingManager.startCameraPreview(in: CALayer())
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

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var recordingManager: VideoRecordingManager
    let onAppear: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        onAppear()
        recordingManager.startCameraPreview(in: view.layer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    RecordingView(
        recordingManager: VideoRecordingManager(),
        overlayManager: OverlayManager()
    )
}
