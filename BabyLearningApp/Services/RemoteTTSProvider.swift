import Foundation

protocol RemoteTTSProviding {
    func generateSpeech(text: String, language: String, voiceId: String) async throws -> Data
}

enum RemoteTTSError: Error {
    case missingAPIKey
    case invalidResponse
    case requestFailed(Int)
    case synthesisFailed(String)
    case missingAudioURL
    case emptyAudioData
}

struct FPTTTSResponse: Decodable {
    let async: String?
    let error: Int
    let message: String?
    let requestId: String?

    enum CodingKeys: String, CodingKey {
        case async
        case error
        case message
        case requestId = "request_id"
    }
}

final class FPTTTSProvider: RemoteTTSProviding {
    private let configProvider: () -> TTSConfig
    private let urlSession: URLSession
    private let maxDownloadAttempts: Int

    init(configProvider: @escaping () -> TTSConfig = { .current }, urlSession: URLSession = .shared, maxDownloadAttempts: Int = 10) {
        self.configProvider = configProvider
        self.urlSession = urlSession
        self.maxDownloadAttempts = maxDownloadAttempts
    }

    func generateSpeech(text: String, language: String, voiceId: String) async throws -> Data {
        let config = configProvider()
        guard let apiKey = config.apiKey, !apiKey.isEmpty else {
            throw RemoteTTSError.missingAPIKey
        }

        var request = URLRequest(url: config.endpoint)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "api-key")
        request.setValue(normalizedVoiceID(voiceId), forHTTPHeaderField: "voice")
        request.setValue(config.speed, forHTTPHeaderField: "speed")
        request.setValue("mp3", forHTTPHeaderField: "format")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.httpBody = Data(text.utf8)

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteTTSError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw RemoteTTSError.requestFailed(httpResponse.statusCode)
        }

        let fptResponse = try JSONDecoder().decode(FPTTTSResponse.self, from: data)
        guard fptResponse.error == 0 else {
            throw RemoteTTSError.synthesisFailed(fptResponse.message ?? "FPT TTS failed")
        }
        guard let audioURLString = fptResponse.async,
              let audioURL = URL(string: audioURLString) else {
            throw RemoteTTSError.missingAudioURL
        }

        return try await downloadGeneratedAudio(from: audioURL)
    }

    private func downloadGeneratedAudio(from url: URL) async throws -> Data {
        for attempt in 0..<maxDownloadAttempts {
            if attempt > 0 {
                try await Task.sleep(for: .seconds(2))
            }

            do {
                let (data, response) = try await urlSession.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse else { continue }
                guard (200..<300).contains(httpResponse.statusCode), !data.isEmpty else { continue }
                return data
            } catch {
                continue
            }
        }

        throw RemoteTTSError.emptyAudioData
    }

    private func normalizedVoiceID(_ voiceId: String) -> String {
        let supportedVoices = ["linhsan", "banmai", "thuminh", "lannhi"]
        return supportedVoices.contains(voiceId) ? voiceId : "linhsan"
    }
}
