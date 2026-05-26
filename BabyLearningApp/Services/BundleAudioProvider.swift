import AVFoundation
import Foundation

final class BundleAudioProvider: NSObject, AudioProviding {
    private let fallbackProvider: AudioProviding
    private let fileAudioProvider = FileAudioProvider()

    init(fallbackProvider: AudioProviding = SpeechAudioProvider()) {
        self.fallbackProvider = fallbackProvider
    }

    func speak(_ text: String, language: String = "vi-VN") async {
        guard let url = bundledAudioURL(for: text, language: language) else {
            await fallbackProvider.speak(text, language: language)
            return
        }

        await fileAudioProvider.play(url: url)
    }

    func stop() {
        fileAudioProvider.stop()
        fallbackProvider.stop()
    }

    private func bundledAudioURL(for text: String, language: String) -> URL? {
        let key = Self.resourceKey(for: text, language: language)
        let supportedExtensions = ["m4a", "mp3", "wav", "caf"]

        for fileExtension in supportedExtensions {
            if let url = Bundle.main.url(forResource: key, withExtension: fileExtension) {
                return url
            }
        }

        return nil
    }

    static func resourceKey(for text: String, language: String) -> String {
        let normalizedText = text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: language))
            .lowercased()

        let allowedCharacters = CharacterSet.alphanumerics
        let slug = normalizedText.unicodeScalars.reduce(into: "") { result, scalar in
            if allowedCharacters.contains(scalar) {
                result.unicodeScalars.append(scalar)
            } else if !result.hasSuffix("_") {
                result.append("_")
            }
        }
        .trimmingCharacters(in: CharacterSet(charactersIn: "_"))

        let languagePrefix = language.replacingOccurrences(of: "-", with: "_").lowercased()
        return "voice_\(languagePrefix)_\(slug)"
    }
}
