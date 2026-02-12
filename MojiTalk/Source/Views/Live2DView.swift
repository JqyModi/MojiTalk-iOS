import SwiftUI
import UIKit
import Combine
import MojiLive2D
import MetalKit

// MARK: - Live2D Controller (Adapter)
/// Acts as a bridge between SwiftUI and the Native Live2D SDK
class Live2DController: ObservableObject {
    static let shared = Live2DController()
    
    @Published var currentExpression: String = "idle"
    @Published var isLoaded: Bool = false
    
    /// Reference to the active MTKView to send commands
    weak var mtkView: MOJiMTKView?
    
    /// Play an audio file and trigger lip sync
    /// - Parameters:
    ///   - filePath: Path to the .wav file
    ///   - targetKey: Unique identifier for the audio
    func playAudio(filePath: String, targetKey: String = UUID().uuidString) {
        mtkView?.loadAndPlayAudioFile(filePath, targetKey: targetKey)
    }
    
    func stopAudio() {
        mtkView?.stopPlayAudio()
    }
    
    func setPlaybackSpeed(_ speed: Float) {
        mtkView?.setAudioPlaybackSpeed(speed)
    }
    
    func setFPS(_ fps: Int) {
        mtkView?.setPreferredFPS(fps)
    }
}

// MARK: - Live2D View
struct Live2DView: UIViewRepresentable {
    func makeUIView(context: Context) -> MOJiMTKView {
        Live2DController.shared.isLoaded = false
        // Load target model (defaulting to suzu)
        let config = MOJiL2DFileManager.L2DModelType.suzu.toConfigurationModel()
        
        let view = MOJiMTKView(configurationModel: config)
        view.backgroundColor = .clear
        view.setPreferredFPS(30) // Default to power saving (idle) mode
        
        // Register view with controller
        Live2DController.shared.mtkView = view
        
        view.onLoadingComplete = {
            DispatchQueue.main.async {
                Live2DController.shared.isLoaded = true
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: MOJiMTKView, context: Context) {
        // Reactive updates
    }
    
    static func dismantleUIView(_ uiView: MOJiMTKView, coordinator: ()) {
        // Clean up reference and stop audio when view is removed
        if Live2DController.shared.mtkView === uiView {
            Live2DController.shared.stopAudio()
            Live2DController.shared.mtkView = nil
            Live2DController.shared.isLoaded = false
        }
    }
}

