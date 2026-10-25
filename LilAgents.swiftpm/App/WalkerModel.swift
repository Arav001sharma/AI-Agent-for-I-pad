import SwiftUI

class WalkerModel: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let videoName: String
    let tintColor: Color

    @Published var xPosition: CGFloat
    @Published var isFacingLeft: Bool = false
    @Published var bubbleText: String = "hi!"
    @Published var isBubbleVisible: Bool = true
    @Published var isCompletion: Bool = true
    @Published var isBusy: Bool = false

    private var speed: CGFloat
    private var travelRemaining: CGFloat = 200
    private var isPaused: Bool = false
    private var pauseTimer: Double = 0
    private var timer: Timer?

    private let thinkingPhrases = [
        "hmm...", "thinking...", "one sec...", "ok hold on",
        "let me check", "working on it", "almost...", "bear with me",
        "on it!", "gimme a sec", "brb", "processing...",
        "hang tight", "just a moment", "figuring it out",
        "crunching...", "reading...", "looking...",
        "cooking...", "vibing...", "digging in"
    ]

    private let completionPhrases = [
        "done!", "all set!", "ready!", "here you go", "got it!",
        "finished!", "ta-da!", "voila!", "boom!"
    ]

    init(name: String, videoName: String, tintColor: Color, initialX: CGFloat, speed: CGFloat) {
        self.name = name
        self.videoName = videoName
        self.tintColor = tintColor
        self.xPosition = initialX
        self.speed = speed

        // Start movement loop safely on next runloop
        DispatchQueue.main.async { [weak self] in
            self?.startLoop()
            self?.autoHideInitialBubble()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func autoHideInitialBubble() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            if !(self?.isBusy ?? false) {
                withAnimation {
                    self?.isBubbleVisible = false
                }
            }
        }
    }

    func startLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { [weak self] _ in
            self?.step()
        }
    }

    private func step() {
        if isPaused {
            pauseTimer -= 0.025
            if pauseTimer <= 0 {
                isPaused = false
                travelRemaining = CGFloat.random(in: 120...320)
                if Bool.random() {
                    isFacingLeft.toggle()
                }
            }
            return
        }

        let delta = (isFacingLeft ? -speed : speed)
        let newX = xPosition + delta
        travelRemaining -= abs(delta)

        // Screen bounds check
        if newX > 900 {
            xPosition = 900
            isFacingLeft = true
            pause()
        } else if newX < 40 {
            xPosition = 40
            isFacingLeft = false
            pause()
        } else {
            xPosition = newX
            if travelRemaining <= 0 {
                pause()
            }
        }
    }

    private func pause() {
        isPaused = true
        pauseTimer = Double.random(in: 1.5...3.5)
    }

    func startThinking() {
        isBusy = true
        isCompletion = false
        bubbleText = thinkingPhrases.randomElement() ?? "thinking..."
        withAnimation {
            isBubbleVisible = true
        }

        Timer.scheduledTimer(withTimeInterval: 2.2, repeats: false) { [weak self] _ in
            if self?.isBusy == true {
                self?.bubbleText = self?.thinkingPhrases.randomElement() ?? "cooking..."
            }
        }
    }

    func stopThinking() {
        isBusy = false
        isCompletion = true
        bubbleText = completionPhrases.randomElement() ?? "done!"
        withAnimation {
            isBubbleVisible = true
        }
        SoundManager.shared.playRandomPing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            if !(self?.isBusy ?? false) {
                withAnimation {
                    self?.isBubbleVisible = false
                }
            }
        }
    }
}
