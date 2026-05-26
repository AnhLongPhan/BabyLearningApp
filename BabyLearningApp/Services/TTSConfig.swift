import Foundation

struct TTSConfig {
    static let bundledFPTAPIKey = "aTtNHKm5deLCkFEUdwkvOyiTjoXlHAqf"

    enum Provider {
        case fptAI
    }

    let provider: Provider
    let apiKey: String?
    let voiceId: String
    let speed: String
    let endpoint: URL

    static var current: TTSConfig {
        TTSConfig(
            provider: .fptAI,
            apiKey: Self.apiKey,
            voiceId: UserDefaults.standard.string(forKey: "fptTTSVoiceId") ?? Self.infoString(for: "FPT_TTS_VOICE_ID") ?? "linhsan",
            speed: Self.infoString(for: "FPT_TTS_SPEED") ?? "",
            endpoint: URL(string: Self.infoString(for: "FPT_TTS_ENDPOINT") ?? "https://api.fpt.ai/hmi/tts/v5")!
        )
    }

    private static var apiKey: String? {
        // Local development can read from Settings, Info.plist, or the process environment.
        // Production apps should call a backend proxy instead of shipping API keys in the app bundle.
        userDefaultString(for: "fptAPIKey")
            ?? infoString(for: "FPT_API_KEY")
            ?? ProcessInfo.processInfo.environment["FPT_API_KEY"]
            ?? bundledFPTAPIKey
    }

    private static func userDefaultString(for key: String) -> String? {
        let value = UserDefaults.standard.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value, !value.isEmpty else { return nil }
        return value
    }

    private static func infoString(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
