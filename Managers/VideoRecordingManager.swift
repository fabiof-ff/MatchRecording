import AVFoundation
import Combine

class VideoRecordingManager: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var highlights: [Highlight] = []
    @Published var errorMessage: String?
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var recordingTimer: Timer?
    private var currentVideoURL: URL?
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            errorMessage = "Fotocamera non disponibile"
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            errorMessage = "Errore nell'accesso alla fotocamera: \(error.localizedDescription)"
            return
        }
        
        // Add audio input
        let audioDevice = AVCaptureDevice.default(for: .audio)
        if let audioDevice = audioDevice {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                }
            } catch {
                print("Errore nell'accesso al microfono: \(error.localizedDescription)")
            }
        }
        
        // Add video output
        let videoOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            self.videoOutput = videoOutput
        }
        
        self.captureSession = session
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        let outputURL = getDocumentsDirectory().appendingPathComponent(
            "match_\(Date().timeIntervalSince1970).mov"
        )
        
        currentVideoURL = outputURL
        videoOutput?.startRecording(to: outputURL, recordingDelegate: self)
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.recordingDuration = 0
            self.startRecordingTimer()
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        videoOutput?.stopRecording()
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    func markHighlight() {
        guard isRecording else { return }
        let highlight = Highlight(
            timestamp: recordingDuration,
            duration: 10,
            date: Date()
        )
        DispatchQueue.main.async {
            self.highlights.append(highlight)
        }
    }
    
    func startCameraPreview(in layer: CALayer) {
        guard let captureSession = captureSession else { return }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = layer.bounds
        
        layer.insertSublayer(previewLayer, at: 0)
        
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        }
    }
    
    func stopCameraPreview() {
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.recordingDuration += 0.1
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo fileURL: URL,
        from connections: [AVCaptureConnection]
    ) {
        print("Registrazione iniziata: \(fileURL)")
    }
    
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        if let error = error {
            print("Errore nella registrazione: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Errore: \(error.localizedDescription)"
            }
        } else {
            print("Registrazione completata: \(outputFileURL)")
            // Video file is ready for export/processing
        }
    }
}

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
