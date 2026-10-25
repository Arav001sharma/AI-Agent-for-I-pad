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

    func updateUIView(_ uiView: PlayerUIView, context: Context) {}
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
        
        guard let url = Bundle.module.url(forResource: videoName, withExtension: "mov") else {
            return
        }

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVQueuePlayer(playerItem: playerItem)
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
