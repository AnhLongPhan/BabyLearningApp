import Foundation

struct AlphabetItem: Identifiable, Equatable {
    let id: UUID
    let letter: String
    let word: String
    let imageName: String
    let speechText: String

    init(id: UUID = UUID(), letter: String, word: String, imageName: String, speechText: String) {
        self.id = id
        self.letter = letter
        self.word = word
        self.imageName = imageName
        self.speechText = speechText
    }
}
