import Foundation

final class AudioService {
    private let provider: AudioProviding
    private var speechTask: Task<Void, Never>?

    init(provider: AudioProviding = CachedAudioService()) {
        self.provider = provider
    }

    func speak(_ text: String, language: String = "vi-VN") {
        speechTask?.cancel()
        provider.stop()
        speechTask = Task {
            await provider.speak(text, language: language)
        }
    }

    func speakAndWait(_ text: String, language: String = "vi-VN") async {
        speechTask?.cancel()
        provider.stop()
        await provider.speak(text, language: language)
    }

    func stop() {
        speechTask?.cancel()
        speechTask = nil
        provider.stop()
    }
}
