import AVFoundation

final class AudioManager: NSObject {
    
    static let shared = AudioManager()
    
    private var recorder: AVAudioRecorder?
    
    // MARK: - Permissions
    
    func requestPermission() async -> Bool {
        print("[Audio] Requesting microphone permission...")
        
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                print("[Audio] Permission granted:", granted)
                continuation.resume(returning: granted)
            }
        }
    }
    
    // MARK: - Start Recording
    
    func startRecording() throws {
        print("[Audio] Starting recording...")
        
        try cleanupRecording()
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)
        
        let url = Self.recordingURL()
        print("[Audio] Recording will save to:", url.path)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        recorder = try AVAudioRecorder(url: url, settings: settings)
        
        let success = recorder?.record() ?? false
        print("[Audio] Recorder started:", success)
    }
    
    // MARK: - Stop Recording
    
    func stopRecording() -> URL? {
        print("[Audio] Stopping recording...")
        
        guard let recorder = recorder else {
            print("[Audio] No active recorder found.")
            return nil
        }
        
        recorder.stop()
        let url = recorder.url
        self.recorder = nil
        
        try? AVAudioSession.sharedInstance().setActive(false)
        
        // Verify file exists
        let fileExists = FileManager.default.fileExists(atPath: url.path)
        print("[Audio] File exists:", fileExists)
        
        if fileExists {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = attributes[.size] as? NSNumber
                print("[Audio] Recording saved successfully.")
                print("[Audio] File size:", fileSize ?? 0, "bytes")
            } catch {
                print("[Audio] Could not read file attributes:", error)
            }
        } else {
            print("[Audio] ERROR: Recording file not found.")
        }
        
        print("[Audio] Recording URL:", url.path)
        print("[Audio] Recording URL for Finder copy:", url.absoluteString)
        
        return url
    }
    
    // MARK: - Cleanup
    
    func cleanupRecording() throws {
        if recorder?.isRecording == true {
            print("[Audio] Cleaning up active recording...")
            recorder?.stop()
        }
        recorder = nil
    }
    
    private static func recordingURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("live_recording.m4a")
    }
}
