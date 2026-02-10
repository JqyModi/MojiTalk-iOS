import Foundation
import Combine
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()
    
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var playingMessageId: UUID?
    
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playAudio(from url: URL, messageId: UUID) {
        isLoading = true
        playingMessageId = messageId
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    self.isLoading = false
                    self.play(data: data, messageId: messageId)
                }
            } catch {
                print("Failed to load audio: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.playingMessageId = nil
                }
            }
        }
    }
    
    func play(data: Data, messageId: UUID) {
        stop()
        
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            playingMessageId = messageId
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        // Note: Don't nil playingMessageId here immediately if we want to toggle
    }
    
    func stopAll() {
        stop()
        // Also stop Live2D audio if any
        Live2DController.shared.stopAudio()
        playingMessageId = nil
        isLoading = false
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.playingMessageId = nil
        }
    }
}
