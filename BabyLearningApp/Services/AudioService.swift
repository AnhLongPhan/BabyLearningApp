import Foundation

final class AudioService {
    private let provider: AudioProviding

    init(provider: AudioProviding = SpeechAudioProvider()) {
        self.provider = provider
    }

    func speak(_ text: String, language: String = "vi-VN") {
        provider.speak(text, language: language)
    }

    func speakAndWait(_ text: String, language: String = "vi-VN") async {
        await provider.speakAndWait(text, language: language)
    }

    func stop() {
        provider.stop()
    }
}

final class FileAudioProvider: AudioProviding {
    func speak(_ text: String, language: String = "vi-VN") {
        // Placeholder for future mp3 playback implementation.
    }

    func speakAndWait(_ text: String, language: String = "vi-VN") async {
        speak(text, language: language)
    }

    func stop() {
        // Placeholder for future mp3 playback implementation.
    }
}
