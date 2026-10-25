import SwiftUI
import AVFoundation
import UIKit

struct TransparentVideoPlayer: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.setupPlayer(videoName: videoName)
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        // Player already running in looper, no need to recreate
    }
}

class PlayerUIView: UIView {
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    func setupPlayer(videoName: String) {
        backgroundColor = .clear

        // Prevent duplicate setups
        if queuePlayer != nil { return }

        guard let url = ResourceHelper.findResource(name: videoName, ext: "mov") else {
            print("Notice: Resource \(videoName).mov not found in bundle, using animated character fallback")
            return
        }

        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        // CRITICAL FIX: AVQueuePlayer MUST be initialized empty!
        // Passing playerItem to both AVQueuePlayer AND AVPlayerLooper crashes with NSInvalidArgumentException.
        let player = AVQueuePlayer()
        looper = AVPlayerLooper(player: player, templateItem: playerItem)

        if let pLayer = layer as? AVPlayerLayer {
            pLayer.player = player
            pLayer.videoGravity = .resizeAspect
            pLayer.pixelBufferAttributes = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
        }

        player.isMuted = true
        player.play()
        self.queuePlayer = player
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.backgroundColor = UIColor.clear.cgColor
    }
}
