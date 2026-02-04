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
    
    // Hold reference to the view if needed, or use a delegate pattern
    // For now, simple pass-through
    
    // TODO: Connect with MOJiMTKView instance
}

// MARK: - Live2D View
struct Live2DView: UIViewRepresentable {
    func makeUIView(context: Context) -> MOJiMTKView {
        // Load target model (defaulting to suzu)
        let config = MOJiL2DFileManager.L2DModelType.suzu.toConfigurationModel()
        
        let view = MOJiMTKView(configurationModel: config)
        view.backgroundColor = .clear
        
        // Adjust content mode if needed, usually MTKView handles scaling internally via Live2D's matrix
        
        return view
    }
    
    func updateUIView(_ uiView: MOJiMTKView, context: Context) {
        // Reactive updates
    }
}

