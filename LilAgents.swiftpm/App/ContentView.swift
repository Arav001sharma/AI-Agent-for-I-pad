import SwiftUI

struct ContentView: View {
    @StateObject private var bruce = WalkerModel(name: "Bruce", videoName: "walk-bruce-01", tintColor: Color(red: 0.4, green: 0.72, blue: 0.55), initialX: 200, speed: 1.2)
    @StateObject private var jazz = WalkerModel(name: "Jazz", videoName: "walk-jazz-01", tintColor: Color(red: 1.0, green: 0.4, blue: 0.0), initialX: 550, speed: 1.4)
    @StateObject private var aiService = AIService()

    @State private var activeCharacter: WalkerModel? = nil
    @State private var showTerminal: Bool = false
    @State private var showSettings: Bool = false

    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(sender: "System", text: "Lil Agents for iPad Pro M1 loaded. Tap Bruce or Jazz to chat!", isUser: false)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                RadialGradient(colors: [Color(red: 0.09, green: 0.11, blue: 0.14), Color(red: 0.03, green: 0.04, blue: 0.05)],
                               center: .center, startRadius: 100, endRadius: 800)
                    .ignoresSafeArea()

                // Subtle grid
                VStack {
                    HStack {
                        Label("lil agents", systemImage: "figure.walk")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    Spacer()
                }

                // Characters Stage
                ZStack(alignment: .bottomLeading) {
                    // Bruce
                    characterView(character: bruce)
                    // Jazz
                    characterView(character: jazz)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.bottom, 110)

                // Simulated iPad Dock
                VStack {
                    Spacer()
                    HStack(spacing: 16) {
                        dockIcon(emoji: "🟢", label: "Bruce", color: bruce.tintColor) {
                            openTerminal(for: bruce)
                        }
                        dockIcon(emoji: "🟠", label: "Jazz", color: jazz.tintColor) {
                            openTerminal(for: jazz)
                        }
                        Divider().frame(height: 36).background(Color.white.opacity(0.2))
                        dockIcon(emoji: "💻", label: "Terminal", color: .blue) {
                            openTerminal(for: activeCharacter ?? bruce)
                        }
                        dockIcon(emoji: "⚙️", label: "Settings", color: .gray) {
                            showSettings = true
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Material.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.2), lineWidth: 1))
                            .shadow(color: .black.opacity(0.5), radius: 30, y: 15)
                    )
                    .padding(.bottom, 16)
                }

                // Terminal Popover
                if showTerminal, let char = activeCharacter {
                    terminalView(for: char)
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            settingsSheet
        }
    }

    @ViewBuilder
    private func characterView(character: WalkerModel) -> some View {
        VStack(spacing: 4) {
            // Speech / Thinking Bubble
            if character.isBubbleVisible {
                HStack(spacing: 6) {
                    Circle()
                        .fill(character.isCompletion ? Color.green : character.tintColor)
                        .frame(width: 6, height: 6)
                    Text(character.bubbleText)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(character.isCompletion ? .green : .white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.85))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(character.tintColor.opacity(0.5), lineWidth: 1))
            }

            // Character Video with fallback avatar
            ZStack {
                TransparentVideoPlayer(videoName: character.videoName)

                VStack(spacing: 4) {
                    Circle()
                        .fill(character.tintColor)
                        .frame(width: 44, height: 44)
                        .overlay(Text("🤖").font(.system(size: 24)))
                        .shadow(color: character.tintColor.opacity(0.4), radius: 6)
                    Text(character.name)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .zIndex(-1)
            }
            .frame(width: 120, height: 180)
            .scaleEffect(x: character.isFacingLeft ? -1 : 1, y: 1)
            .onTapGesture {
                openTerminal(for: character)
            }
        }
        .position(x: character.xPosition, y: 400)
    }

    @ViewBuilder
    private func dockIcon(emoji: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: 26))
                .frame(width: 52, height: 52)
                .background(Color.white.opacity(0.12))
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.4), lineWidth: 1))
        }
    }

    @ViewBuilder
    private func terminalView(for character: WalkerModel) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle().fill(character.tintColor).frame(width: 8, height: 8)
                Text("\(character.name.uppercased()) // \(aiService.selectedProvider.rawValue.uppercased())")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(character.tintColor)
                Spacer()
                Button(action: { showTerminal = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(6)
                }
            }
            .padding()
            .background(Color(white: 0.12))

            Divider().background(character.tintColor.opacity(0.3))

            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(msg.sender)
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(msg.isUser ? .orange : character.tintColor)
                                Text(msg.text)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(8)
                            }
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            Divider().background(Color.white.opacity(0.1))

            // Input Bar
            HStack(spacing: 8) {
                TextField("Ask \(character.name)...", text: $inputText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, design: .monospaced))
                    .padding(8)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .onSubmit { sendMessage(for: character) }

                Button(action: { sendMessage(for: character) }) {
                    Text("Send")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(character.tintColor)
                        .cornerRadius(8)
                }
            }
            .padding(12)
            .background(Color(white: 0.12))
        }
        .frame(width: 480, height: 420)
        .background(Color(red: 0.08, green: 0.08, blue: 0.09).opacity(0.95))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(character.tintColor, lineWidth: 1.5))
        .shadow(color: .black.opacity(0.6), radius: 30)
    }

    private var settingsSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("AI Provider")) {
                    Picker("Provider", selection: $aiService.selectedProvider) {
                        ForEach(AIProviderType.allCases) { prov in
                            Text(prov.rawValue).tag(prov)
                        }
                    }
                }

                if aiService.selectedProvider == .gemini {
                    Section(header: Text("Google Gemini API Key")) {
                        SecureField("Enter Gemini API Key", text: $aiService.geminiKey)
                    }
                } else if aiService.selectedProvider == .claude {
                    Section(header: Text("Anthropic Claude API Key")) {
                        SecureField("Enter Claude API Key", text: $aiService.claudeKey)
                    }
                } else if aiService.selectedProvider == .openai {
                    Section(header: Text("OpenAI API Key")) {
                        SecureField("Enter OpenAI Key", text: $aiService.openAIKey)
                    }
                }

                Section(footer: Text("Lil Agents runs locally on Apple M1 iPad Pro (iPadOS 16.7+).")) {
                    Button("Save & Close") {
                        aiService.save()
                        showSettings = false
                    }
                }
            }
            .navigationTitle("Agent Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        aiService.save()
                        showSettings = false
                    }
                }
            }
        }
    }

    private func openTerminal(for character: WalkerModel) {
        activeCharacter = character
        withAnimation(.spring()) {
            showTerminal = true
        }
    }

    private func sendMessage(for character: WalkerModel) {
        let q = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        inputText = ""

        messages.append(ChatMessage(sender: "You", text: q, isUser: true))
        character.startThinking()

        Task {
            do {
                let ans = try await aiService.query(characterName: character.name, prompt: q)
                await MainActor.run {
                    character.stopThinking()
                    messages.append(ChatMessage(sender: character.name, text: ans, isUser: false))
                }
            } catch {
                await MainActor.run {
                    character.stopThinking()
                    messages.append(ChatMessage(sender: character.name, text: "Error: \(error.localizedDescription)", isUser: false))
                }
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: String
    let text: String
    let isUser: Bool
}
