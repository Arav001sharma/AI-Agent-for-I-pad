import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    private let soundNames = [
        "ping-aa", "ping-bb", "ping-cc", "ping-dd",
        "ping-ee", "ping-ff", "ping-gg", "ping-hh"
    ]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func playRandomPing() {
        guard let name = soundNames.randomElement() else { return }
        if let url = Bundle.module.url(forResource: name, withExtension: "mp3", subdirectory: "Sounds") ??
                     Bundle.module.url(forResource: name, withExtension: "mp3") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
    }
}
