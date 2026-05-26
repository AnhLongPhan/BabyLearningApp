import Foundation

final class CachedAudioService: AudioProviding {
    private let cacheManager: AudioCacheManager
    private let remoteProvider: RemoteTTSProviding
    private let fileAudioProvider: FileAudioProvider
    private let fallbackProvider: AudioProviding
    private let voiceIdProvider: () -> String
    private var inFlightTasks: [String: Task<URL, Error>] = [:]

    init(
        cacheManager: AudioCacheManager = AudioCacheManager(),
        remoteProvider: RemoteTTSProviding = FPTTTSProvider(),
        fileAudioProvider: FileAudioProvider = FileAudioProvider(),
        fallbackProvider: AudioProviding = SpeechAudioProvider(),
        voiceIdProvider: @escaping () -> String = { TTSConfig.current.voiceId }
    ) {
        self.cacheManager = cacheManager
        self.remoteProvider = remoteProvider
        self.fileAudioProvider = fileAudioProvider
        self.fallbackProvider = fallbackProvider
        self.voiceIdProvider = voiceIdProvider
    }

    func speak(_ text: String, language: String = "vi-VN") async {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        do {
            let voiceId = voiceIdProvider()
            if let cachedURL = try await cacheManager.cachedFileURL(for: trimmedText, language: language, voiceId: voiceId) {
                await fileAudioProvider.play(url: cachedURL)
                return
            }

            let generatedURL = try await generatedAudioURL(for: trimmedText, language: language, voiceId: voiceId)
            await fileAudioProvider.play(url: generatedURL)
        } catch {
            await fallbackProvider.speak(trimmedText, language: language)
        }
    }

    func stop() {
        inFlightTasks.values.forEach { $0.cancel() }
        inFlightTasks.removeAll()
        fileAudioProvider.stop()
        fallbackProvider.stop()
    }

    private func generatedAudioURL(for text: String, language: String, voiceId: String) async throws -> URL {
        let cacheKey = await cacheManager.cacheKey(for: text, language: language, voiceId: voiceId)

        if let existingTask = inFlightTasks[cacheKey] {
            return try await existingTask.value
        }

        let task = Task<URL, Error> {
            let data = try await remoteProvider.generateSpeech(text: text, language: language, voiceId: voiceId)
            return try await cacheManager.saveAudioData(data, text: text, language: language, voiceId: voiceId)
        }
        inFlightTasks[cacheKey] = task

        do {
            let url = try await task.value
            inFlightTasks[cacheKey] = nil
            return url
        } catch {
            inFlightTasks[cacheKey] = nil
            throw error
        }
    }
}
