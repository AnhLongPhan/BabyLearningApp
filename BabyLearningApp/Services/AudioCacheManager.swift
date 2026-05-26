import CryptoKit
import Foundation

struct AudioCacheRecord: Codable {
    let cacheKey: String
    let fileName: String
    let originalText: String
    let language: String
    let voiceId: String
    let createdAt: Date
}

actor AudioCacheManager {
    private let folderName = "GeneratedAudio"
    private let metadataDefaultsKey = "generatedAudioMetadata"
    private let fileManager: FileManager
    private let userDefaults: UserDefaults

    init(fileManager: FileManager = .default, userDefaults: UserDefaults = .standard) {
        self.fileManager = fileManager
        self.userDefaults = userDefaults
    }

    func cachedFileURL(for text: String, language: String, voiceId: String) throws -> URL? {
        let key = cacheKey(for: text, language: language, voiceId: voiceId)
        let fileName = fileName(for: key)
        let url = try cacheDirectoryURL().appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    func saveAudioData(_ data: Data, text: String, language: String, voiceId: String) throws -> URL {
        let key = cacheKey(for: text, language: language, voiceId: voiceId)
        let fileName = fileName(for: key)
        let directoryURL = try cacheDirectoryURL()
        let fileURL = directoryURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: [.atomic])

        var metadata = loadMetadata()
        metadata[key] = AudioCacheRecord(
            cacheKey: key,
            fileName: fileName,
            originalText: text,
            language: language,
            voiceId: voiceId,
            createdAt: Date()
        )
        saveMetadata(metadata)

        return fileURL
    }

    func cacheKey(for text: String, language: String, voiceId: String) -> String {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let source = "\(normalizedText)|\(language)|\(voiceId)"
        let digest = SHA256.hash(data: Data(source.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func fileName(for cacheKey: String) -> String {
        "generated_audio_\(cacheKey).mp3"
    }

    private func cacheDirectoryURL() throws -> URL {
        let cachesURL = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = cachesURL.appendingPathComponent(folderName, isDirectory: true)

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        return directoryURL
    }

    private func loadMetadata() -> [String: AudioCacheRecord] {
        guard let data = userDefaults.data(forKey: metadataDefaultsKey),
              let metadata = try? JSONDecoder().decode([String: AudioCacheRecord].self, from: data) else {
            return [:]
        }
        return metadata
    }

    private func saveMetadata(_ metadata: [String: AudioCacheRecord]) {
        guard let data = try? JSONEncoder().encode(metadata) else { return }
        userDefaults.set(data, forKey: metadataDefaultsKey)
    }
}
