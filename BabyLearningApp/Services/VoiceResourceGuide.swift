import Foundation

enum VoiceResourceGuide {
    static let folderSuggestion = "VoiceResources"

    static func fileName(for text: String, language: String = "vi-VN", fileExtension: String = "m4a") -> String {
        "\(BundleAudioProvider.resourceKey(for: text, language: language)).\(fileExtension)"
    }

    static let examples: [String] = [
        BundleAudioProvider.resourceKey(for: "Giỏi quá Bé!", language: "vi-VN") + ".m4a",
        BundleAudioProvider.resourceKey(for: "Bé ơi, hãy tìm chữ A nhé", language: "vi-VN") + ".m4a",
        BundleAudioProvider.resourceKey(for: "Đây là chữ A", language: "vi-VN") + ".m4a"
    ]
}
