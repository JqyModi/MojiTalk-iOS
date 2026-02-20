import Foundation
import Combine
import AVFoundation
import Speech

class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    static let shared = AudioRecorderManager()
    
    @Published var isRecording = false
    @Published var audioPower: Float = 0.0
    
    var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    override init() {
        super.init()
    }
    
    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            print("Microphone permission allowed: \(allowed)")
        }
        SFSpeechRecognizer.requestAuthorization { status in
            print("Speech recognition authorization status: \(status.rawValue)")
        }
    }
    
    // ... (existing codes)
    
    func transcribe(url: URL) async throws -> String {
        // Try to initialize with Chinese locale, fallback to current or Japanese
        let locale = Locale(identifier: "zh-CN")
        guard let recognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer(), recognizer.isAvailable else {
            throw NSError(domain: "AudioRecorderManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"])
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        // Force server-side recognition if available for better accuracy, though on-device is requested for 0 cost.
        // options: .requiresOnDeviceRecognition
        if #available(iOS 13, *) {
            request.requiresOnDeviceRecognition = false // Allow server offload for better accuracy/language support if needed?
            // But user asked for 0 cost. Apple server ASR is free but requires network.
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
    
    func cleanAudioSession() {
        do {
            // 设置 Audio Session 类别为 PlayAndRecord，支持录音和播放
            // .defaultToSpeaker 确保录音结束后播放声音走扬声器而不是听筒
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session for recording: \(error)")
        }
    }
    
    func startRecording() -> URL? {
        cleanAudioSession()
        
        // Ensure directory exists
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let docsDir = paths.first else { return nil }
        
        let audioFilename = docsDir.appendingPathComponent("voice_msg_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            startMonitoring()
            print("Started recording to \(audioFilename)")
            return audioFilename
        } catch {
            print("Could not start recording: \(error)")
            return nil
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        stopMonitoring()
        print("Stopped recording")
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let recorder = self.audioRecorder else { return }
            recorder.updateMeters()
            self.audioPower = recorder.averagePower(forChannel: 0)
        }
    }
    
    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        audioPower = 0.0
    }
}
