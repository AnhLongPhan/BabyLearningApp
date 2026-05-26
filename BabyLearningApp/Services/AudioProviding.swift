import Foundation

protocol AudioProviding {
    func speak(_ text: String, language: String) async
    func stop()
}

extension AudioProviding {
    func speak(_ text: String) async {
        await speak(text, language: "vi-VN")
    }
}
