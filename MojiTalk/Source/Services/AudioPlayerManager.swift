import Foundation
import Combine
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()
    
    @Published var isPlaying = false
    @Published var playingMessageId: UUID?
    
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playAudio(from url: URL, messageId: UUID) {
        // In a real app, we'd download the audio first or use AVPlayer for streaming.
        // For MVP/Demo, let's assume we have a local path or use simple data loading.
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    self.play(data: data, messageId: messageId)
                }
            } catch {
                print("Failed to load audio: \(error)")
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
        isPlaying = false
        playingMessageId = nil
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.playingMessageId = nil
        }
    }
}
