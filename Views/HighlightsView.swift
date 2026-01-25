import SwiftUI

struct HighlightsView: View {
    @ObservedObject var recordingManager: VideoRecordingManager
    @State private var selectedHighlight: Highlight?
    @State private var showExportOptions = false
    
    var body: some View {
        VStack {
            if recordingManager.highlights.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Nessun Highlight")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Registra una partita e marca i momenti salienti")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.05))
            } else {
                List {
                    ForEach(recordingManager.highlights) { highlight in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                
                                Text("Highlight")
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text(highlight.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Durata: \(String(format: "%.1f", highlight.duration))s")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(highlight.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: deleteHighlight)
                }
                
                VStack(spacing: 12) {
                    Button(action: { showExportOptions = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Esporta Highlights")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                    }
                    
                    Button(action: { clearAllHighlights() }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Cancella Tutto")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Highlights")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExportOptions) {
            ExportOptionsView(recordingManager: recordingManager)
        }
    }
    
    private func deleteHighlight(at offsets: IndexSet) {
        recordingManager.highlights.remove(atOffsets: offsets)
    }
    
    private func clearAllHighlights() {
        recordingManager.highlights.removeAll()
    }
}

struct ExportOptionsView: View {
    @ObservedObject var recordingManager: VideoRecordingManager
    @Environment(\.dismiss) var dismiss
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Opzioni di Esportazione")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Highlights: \(recordingManager.highlights.count)", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Label("Durata totale: \(calculateTotalDuration())s", systemImage: "clock")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Formato di Esportazione")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "film.fill")
                                .foregroundColor(.blue)
                            Text("MP4 (Consigliato)")
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(.purple)
                            Text("MOV")
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .padding()
                
                if isExporting {
                    VStack(spacing: 12) {
                        ProgressView(value: exportProgress)
                            .tint(.blue)
                        
                        Text("Esportazione in corso...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("Annulla")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    
                    Button(action: { startExport() }) {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                            Text("Esporta MP4")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .fontWeight(.semibold)
                    }
                    .disabled(isExporting || recordingManager.highlights.isEmpty)
                }
            }
            .padding()
            .navigationTitle("Esporta")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func calculateTotalDuration() -> String {
        let total = recordingManager.highlights.reduce(0) { $0 + $1.duration }
        return String(format: "%.1f", total)
    }
    
    private func startExport() {
        isExporting = true
        exportProgress = 0
        
        // Simulate export process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exportProgress = 0.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            exportProgress = 0.7
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            exportProgress = 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isExporting = false
                dismiss()
            }
        }
    }
}

#Preview {
    HighlightsView(recordingManager: VideoRecordingManager())
}
