import Foundation

enum AIProviderType: String, CaseIterable, Identifiable {
    case gemini = "Gemini"
    case claude = "Claude"
    case openai = "OpenAI"
    case demo = "Demo Mode"

    var id: String { rawValue }
}

class AIService: ObservableObject {
    @Published var selectedProvider: AIProviderType = .demo
    @Published var geminiKey: String = ""
    @Published var claudeKey: String = ""
    @Published var openAIKey: String = ""

    init() {
        if let saved = UserDefaults.standard.string(forKey: "saved_provider"),
           let prov = AIProviderType(rawValue: saved) {
            selectedProvider = prov
        }
        geminiKey = UserDefaults.standard.string(forKey: "key_gemini") ?? ""
        claudeKey = UserDefaults.standard.string(forKey: "key_claude") ?? ""
        openAIKey = UserDefaults.standard.string(forKey: "key_openai") ?? ""
    }

    func save() {
        UserDefaults.standard.set(selectedProvider.rawValue, forKey: "saved_provider")
        UserDefaults.standard.set(geminiKey, forKey: "key_gemini")
        UserDefaults.standard.set(claudeKey, forKey: "key_claude")
        UserDefaults.standard.set(openAIKey, forKey: "key_openai")
    }

    func query(characterName: String, prompt: String) async throws -> String {
        switch selectedProvider {
        case .gemini:
            guard !geminiKey.isEmpty else {
                return generateDemoResponse(characterName: characterName, prompt: prompt)
            }
            return try await callGemini(characterName: characterName, prompt: prompt)

        case .claude:
            guard !claudeKey.isEmpty else {
                return generateDemoResponse(characterName: characterName, prompt: prompt)
            }
            return try await callClaude(characterName: characterName, prompt: prompt)

        case .openai:
            guard !openAIKey.isEmpty else {
                return generateDemoResponse(characterName: characterName, prompt: prompt)
            }
            return try await callOpenAI(characterName: characterName, prompt: prompt)

        case .demo:
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            return generateDemoResponse(characterName: characterName, prompt: prompt)
        }
    }

    private func callGemini(characterName: String, prompt: String) async throws -> String {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(geminiKey)") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": "You are \(characterName), a tiny AI companion walking on an iPad Pro dock. Be concise and witty.\n\nUser: \(prompt)"]]]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let candidates = json?["candidates"] as? [[String: Any]],
           let content = candidates.first?["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let text = parts.first?["text"] as? String {
            return text
        }
        return "I heard you, but have no answer right now!"
    }

    private func callClaude(characterName: String, prompt: String) async throws -> String {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(claudeKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1024,
            "messages": [["role": "user", "content": prompt]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let content = json?["content"] as? [[String: Any]],
           let text = content.first?["text"] as? String {
            return text
        }
        return "No response from Claude."
    }

    private func callOpenAI(characterName: String, prompt: String) async throws -> String {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are \(characterName), a tiny AI companion on iPad Pro."],
                ["role": "user", "content": prompt]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let choices = json?["choices"] as? [[String: Any]],
           let msg = choices.first?["message"] as? [String: Any],
           let text = msg["content"] as? String {
            return text
        }
        return "No response from OpenAI."
    }

    private func generateDemoResponse(characterName: String, prompt: String) -> String {
        let p = prompt.lowercased()
        if p.contains("hi") || p.contains("hello") {
            return "Hey! I'm \(characterName), taking a stroll on your iPad M1 Pro dock. How can I help you today?"
        }
        if p.contains("who are you") {
            return "I'm \(characterName), your lil AI buddy. You can configure my Gemini, Claude, or OpenAI key in settings!"
        }
        return "That's an interesting thought! You asked: \"\(prompt)\". Configure my live API key in settings for real-time web AI answers!"
    }
}
