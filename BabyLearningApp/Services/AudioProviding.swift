import Foundation

protocol AudioProviding {
    func speak(_ text: String, language: String)
    func speakAndWait(_ text: String, language: String) async
    func stop()
}

extension AudioProviding {
    func speak(_ text: String) {
        speak(text, language: "vi-VN")
    }

    func speakAndWait(_ text: String) async {
        await speakAndWait(text, language: "vi-VN")
    }
}
